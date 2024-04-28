// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
abstract contract Initializable {
    bool private _initialized;
    bool private _initializing;
    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");
        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}
library Address {
    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC1155Receiver is IERC165 {
    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);
    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);
}
abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}
abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}
contract ERC1155Holder is ERC1155Receiver {
    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }
}
interface IERC1155 is IERC165 {
    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);
    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);
    function setApprovalForAll(address operator, bool approved) external;
    function isApprovedForAll(address account, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;
    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;
}
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
contract ERC721Holder is IERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }
    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }
    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }
    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }
}
interface ICallWhitelist {
    event CallAdded(address operator, address callee, bytes4 selector);
    event CallRemoved(address operator, address callee, bytes4 selector);
    function isWhitelisted(address callee, bytes4 selector) external view returns (bool);
    function isBlacklisted(bytes4 selector) external view returns (bool);
    function add(address callee, bytes4 selector) external;
    function remove(address callee, bytes4 selector) external;
}
interface ICallDelegator {
    function canCallOn(address caller, address vault) external view returns (bool);
}
interface IAssetVault {
    event WithdrawEnabled(address operator);
    event WithdrawERC20(address indexed operator, address indexed token, address recipient, uint256 amount);
    event WithdrawERC721(address indexed operator, address indexed token, address recipient, uint256 tokenId);
    event WithdrawPunk(address indexed operator, address indexed token, address recipient, uint256 tokenId);
    event WithdrawERC1155(
        address indexed operator,
        address indexed token,
        address recipient,
        uint256 tokenId,
        uint256 amount
    );
    event WithdrawETH(address indexed operator, address indexed recipient, uint256 amount);
    event Call(address indexed operator, address indexed to, bytes data);
    function initialize(address _whitelist) external;
    function withdrawEnabled() external view returns (bool);
    function whitelist() external view returns (ICallWhitelist);
    function enableWithdraw() external;
    function withdrawERC20(address token, address to) external;
    function withdrawERC721(
        address token,
        uint256 tokenId,
        address to
    ) external;
    function withdrawERC1155(
        address token,
        uint256 tokenId,
        address to
    ) external;
    function withdrawETH(address to) external;
    function withdrawPunk(
        address punks,
        uint256 punkIndex,
        address to
    ) external;
    function call(address to, bytes memory data) external;
}
interface IPunks {
    function punkIndexToAddress(uint256 punkIndex) external view returns (address owner);
    function buyPunk(uint256 punkIndex) external;
    function transferPunk(address to, uint256 punkIndex) external;
}
interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
}
error AV_WithdrawsDisabled();
error AV_WithdrawsEnabled();
error AV_AlreadyInitialized(address ownershipToken);
error AV_CallDisallowed(address caller);
error AV_NonWhitelistedCall(address to, bytes4 data);
error OERC721_CallerNotOwner(address caller);
error VF_InvalidTemplate(address template);
error VF_TokenIdOutOfBounds(uint256 tokenId);
error VF_NoTransferWithdrawEnabled(uint256 tokenId);
abstract contract OwnableERC721 {
    address public ownershipToken;
    function owner() public view virtual returns (address ownerAddress) {
        return IERC721(ownershipToken).ownerOf(uint256(uint160(address(this))));
    }
    function _setNFT(address _ownershipToken) internal {
        ownershipToken = _ownershipToken;
    }
    modifier onlyOwner() {
        if (owner() != msg.sender) revert OERC721_CallerNotOwner(msg.sender);
        _;
    }
}
contract AssetVault is IAssetVault, OwnableERC721, Initializable, ERC1155Holder, ERC721Holder, ReentrancyGuard {
    using Address for address;
    using Address for address payable;
    using SafeERC20 for IERC20;
    bool public override withdrawEnabled;
    ICallWhitelist public override whitelist;
    constructor() {
        withdrawEnabled = true;
        OwnableERC721._setNFT(msg.sender);
    }
    function initialize(address _whitelist) external override initializer {
        if (withdrawEnabled || ownershipToken != address(0)) revert AV_AlreadyInitialized(ownershipToken);
        OwnableERC721._setNFT(msg.sender);
        whitelist = ICallWhitelist(_whitelist);
    }
    function owner() public view override returns (address ownerAddress) {
        return OwnableERC721.owner();
    }
    function enableWithdraw() external override onlyOwner onlyWithdrawDisabled {
        withdrawEnabled = true;
        emit WithdrawEnabled(msg.sender);
    }
    function withdrawERC20(address token, address to) external override onlyOwner onlyWithdrawEnabled {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(to, balance);
        emit WithdrawERC20(msg.sender, token, to, balance);
    }
    function withdrawERC721(
        address token,
        uint256 tokenId,
        address to
    ) external override onlyOwner onlyWithdrawEnabled {
        IERC721(token).safeTransferFrom(address(this), to, tokenId);
        emit WithdrawERC721(msg.sender, token, to, tokenId);
    }
    function withdrawERC1155(
        address token,
        uint256 tokenId,
        address to
    ) external override onlyOwner onlyWithdrawEnabled {
        uint256 balance = IERC1155(token).balanceOf(address(this), tokenId);
        IERC1155(token).safeTransferFrom(address(this), to, tokenId, balance, "");
        emit WithdrawERC1155(msg.sender, token, to, tokenId, balance);
    }
    function withdrawETH(address to) external override onlyOwner onlyWithdrawEnabled nonReentrant {
        uint256 balance = address(this).balance;
        payable(to).sendValue(balance);
        emit WithdrawETH(msg.sender, to, balance);
    }
    function withdrawPunk(
        address punks,
        uint256 punkIndex,
        address to
    ) external override onlyOwner onlyWithdrawEnabled {
        IPunks(punks).transferPunk(to, punkIndex);
        emit WithdrawPunk(msg.sender, punks, to, punkIndex);
    }
    function call(address to, bytes calldata data) external override onlyWithdrawDisabled nonReentrant {
        if (msg.sender != owner() && !ICallDelegator(owner()).canCallOn(msg.sender, address(this)))
            revert AV_CallDisallowed(msg.sender);
        if (!whitelist.isWhitelisted(to, bytes4(data[:4]))) revert AV_NonWhitelistedCall(to, bytes4(data[:4]));
        to.functionCall(data);
        emit Call(msg.sender, to, data);
    }
    modifier onlyWithdrawEnabled() {
        if (!withdrawEnabled) revert AV_WithdrawsDisabled();
        _;
    }
    modifier onlyWithdrawDisabled() {
        if (withdrawEnabled) revert AV_WithdrawsEnabled();
        _;
    }
    receive() external payable {}
}
