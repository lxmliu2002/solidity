// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.7.5;
contract WalletSimple {
  event Deposited(address from, uint256 value, bytes data);
  event SafeModeActivated(address msgSender);
  event Transacted(
    address msgSender, 
    address otherSigner, 
    bytes32 operation, 
    address toAddress, 
    uint256 value, 
    bytes data 
  );
  event BatchTransfer(address sender, address recipient, uint256 value);
  event BatchTransacted(
    address msgSender, 
    address otherSigner, 
    bytes32 operation 
  );
  mapping(address => bool) public signers; 
  bool public safeMode = false; 
  bool public initialized = false; 
  uint256 private constant MAX_SEQUENCE_ID_INCREASE = 10000;
  uint256 constant SEQUENCE_ID_WINDOW_SIZE = 10;
  uint256[SEQUENCE_ID_WINDOW_SIZE] recentSequenceIds;
  function init(address[] calldata allowedSigners) external onlyUninitialized {
    require(allowedSigners.length == 3, 'Invalid number of signers');
    for (uint8 i = 0; i < allowedSigners.length; i++) {
      require(allowedSigners[i] != address(0), 'Invalid signer');
      signers[allowedSigners[i]] = true;
    }
    initialized = true;
  }
  function getNetworkId() internal virtual pure returns (string memory) {
    return 'ETHER';
  }
  function getTokenNetworkId() internal virtual pure returns (string memory) {
    return 'ERC20';
  }
  function getBatchNetworkId() internal virtual pure returns (string memory) {
    return 'ETHER-Batch';
  }
  function isSigner(address signer) public view returns (bool) {
    return signers[signer];
  }
  modifier onlySigner {
    require(isSigner(msg.sender), 'Non-signer in onlySigner method');
    _;
  }
  modifier onlyUninitialized {
    require(!initialized, 'Contract already initialized');
    _;
  }
  fallback() external payable {
    if (msg.value > 0) {
      Deposited(msg.sender, msg.value, msg.data);
    }
  }
  receive() external payable {
    if (msg.value > 0) {
      Deposited(msg.sender, msg.value, msg.data);
    }
  }
  function sendMultiSig(
    address toAddress,
    uint256 value,
    bytes calldata data,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getNetworkId(),
        toAddress,
        value,
        data,
        expireTime,
        sequenceId
      )
    );
    address otherSigner = verifyMultiSig(
      toAddress,
      operationHash,
      signature,
      expireTime,
      sequenceId
    );
    (bool success, ) = toAddress.call{ value: value }(data);
    require(success, 'Call execution failed');
    emit Transacted(
      msg.sender,
      otherSigner,
      operationHash,
      toAddress,
      value,
      data
    );
  }
  function sendMultiSigBatch(
    address[] calldata recipients,
    uint256[] calldata values,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    require(recipients.length != 0, 'Not enough recipients');
    require(
      recipients.length == values.length,
      'Unequal recipients and values'
    );
    require(recipients.length < 256, 'Too many recipients, max 255');
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getBatchNetworkId(),
        recipients,
        values,
        expireTime,
        sequenceId
      )
    );
    require(!safeMode, 'Batch in safe mode');
    address otherSigner = verifyMultiSig(
      address(0x0),
      operationHash,
      signature,
      expireTime,
      sequenceId
    );
    batchTransfer(recipients, values);
    emit BatchTransacted(msg.sender, otherSigner, operationHash);
  }
  function batchTransfer(
    address[] calldata recipients,
    uint256[] calldata values
  ) internal {
    for (uint256 i = 0; i < recipients.length; i++) {
      require(address(this).balance >= values[i], 'Insufficient funds');
      (bool success, ) = recipients[i].call{ value: values[i] }('');
      require(success, 'Call failed');
      emit BatchTransfer(msg.sender, recipients[i], values[i]);
    }
  }
  function sendMultiSigToken(
    address toAddress,
    uint256 value,
    address tokenContractAddress,
    uint256 expireTime,
    uint256 sequenceId,
    bytes calldata signature
  ) external onlySigner {
    bytes32 operationHash = keccak256(
      abi.encodePacked(
        getTokenNetworkId(),
        toAddress,
        value,
        tokenContractAddress,
        expireTime,
        sequenceId
      )
    );
    verifyMultiSig(toAddress, operationHash, signature, expireTime, sequenceId);
    TransferHelper.safeTransfer(tokenContractAddress, toAddress, value);
  }
  function flushForwarderTokens(
    address payable forwarderAddress,
    address tokenContractAddress
  ) external onlySigner {
    Forwarder forwarder = Forwarder(forwarderAddress);
    forwarder.flushTokens(tokenContractAddress);
  }
  function verifyMultiSig(
    address toAddress,
    bytes32 operationHash,
    bytes calldata signature,
    uint256 expireTime,
    uint256 sequenceId
  ) private returns (address) {
    address otherSigner = recoverAddressFromSignature(operationHash, signature);
    require(!safeMode || isSigner(toAddress), 'External transfer in safe mode');
    require(expireTime >= block.timestamp, 'Transaction expired');
    tryInsertSequenceId(sequenceId);
    require(isSigner(otherSigner), 'Invalid signer');
    require(otherSigner != msg.sender, 'Signers cannot be equal');
    return otherSigner;
  }
  function activateSafeMode() external onlySigner {
    safeMode = true;
    SafeModeActivated(msg.sender);
  }
  function recoverAddressFromSignature(
    bytes32 operationHash,
    bytes memory signature
  ) private pure returns (address) {
    require(signature.length == 65, 'Invalid signature - wrong length');
    bytes32 r;
    bytes32 s;
    uint8 v;
    assembly {
      r := mload(add(signature, 32))
      s := mload(add(signature, 64))
      v := and(mload(add(signature, 65)), 255)
    }
    if (v < 27) {
      v += 27; 
    }
    require(
      uint256(s) <=
        0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0,
      "ECDSA: invalid signature 's' value"
    );
    return ecrecover(operationHash, v, r, s);
  }
  function tryInsertSequenceId(uint256 sequenceId) private onlySigner {
    uint256 lowestValueIndex = 0;
    uint256[SEQUENCE_ID_WINDOW_SIZE] memory _recentSequenceIds = recentSequenceIds;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      require(_recentSequenceIds[i] != sequenceId, 'Sequence ID already used');
      if (_recentSequenceIds[i] < _recentSequenceIds[lowestValueIndex]) {
        lowestValueIndex = i;
      }
    }
    require(
      sequenceId > _recentSequenceIds[lowestValueIndex],
      'Sequence ID below window'
    );
    require(
      sequenceId <=
        (_recentSequenceIds[lowestValueIndex] + MAX_SEQUENCE_ID_INCREASE),
      'Sequence ID above maximum'
    );
    recentSequenceIds[lowestValueIndex] = sequenceId;
  }
  function getNextSequenceId() public view returns (uint256) {
    uint256 highestSequenceId = 0;
    for (uint256 i = 0; i < SEQUENCE_ID_WINDOW_SIZE; i++) {
      if (recentSequenceIds[i] > highestSequenceId) {
        highestSequenceId = recentSequenceIds[i];
      }
    }
    return highestSequenceId + 1;
  }
}
