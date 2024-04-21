// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.18;
library AddressUpgradeable {
    function isContract(address account) internal view returns (bool) {
        return account.code.length > 0;
    }
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }
    function _revert(bytes memory returndata, string memory errorMessage) private pure {
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
abstract contract Initializable {
    uint8 private _initialized;
    bool private _initializing;
    event Initialized(uint8 version);
    modifier initializer() {
        bool isTopLevelCall = !_initializing;
        require(
            (isTopLevelCall && _initialized < 1) || (!AddressUpgradeable.isContract(address(this)) && _initialized == 1),
            "Initializable: contract is already initialized"
        );
        _initialized = 1;
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }
    modifier reinitializer(uint8 version) {
        require(!_initializing && _initialized < version, "Initializable: contract is already initialized");
        _initialized = version;
        _initializing = true;
        _;
        _initializing = false;
        emit Initialized(version);
    }
    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }
    function _disableInitializers() internal virtual {
        require(!_initializing, "Initializable: contract is initializing");
        if (_initialized != type(uint8).max) {
            _initialized = type(uint8).max;
            emit Initialized(type(uint8).max);
        }
    }
    function _getInitializedVersion() internal view returns (uint8) {
        return _initialized;
    }
    function _isInitializing() internal view  returns (bool) {
        return _initializing;
    }
}
interface IERC165Upgradeable {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
interface IERC721Upgradeable is IERC165Upgradeable {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address operator);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}
interface IERC721ReceiverUpgradeable {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
interface IERC721MetadataUpgradeable is IERC721Upgradeable {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}
abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }
    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}
library MathUpgradeable {
    enum Rounding {
        Down, 
        Up, 
        Zero 
    }
    function max(uint256 a, uint256 b) internal pure returns (uint256) {
        return a > b ? a : b;
    }
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
    function average(uint256 a, uint256 b) internal pure returns (uint256) {
        return (a & b) + (a ^ b) / 2;
    }
    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {
        return a == 0 ? 0 : (a - 1) / b + 1;
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator) internal pure returns (uint256 result) {
        unchecked {
            uint256 prod0; 
            uint256 prod1; 
            assembly {
                let mm := mulmod(x, y, not(0))
                prod0 := mul(x, y)
                prod1 := sub(sub(mm, prod0), lt(mm, prod0))
            }
            if (prod1 == 0) {
                return prod0 / denominator;
            }
            require(denominator > prod1, "Math: mulDiv overflow");
            uint256 remainder;
            assembly {
                remainder := mulmod(x, y, denominator)
                prod1 := sub(prod1, gt(remainder, prod0))
                prod0 := sub(prod0, remainder)
            }
            uint256 twos = denominator & (~denominator + 1);
            assembly {
                denominator := div(denominator, twos)
                prod0 := div(prod0, twos)
                twos := add(div(sub(0, twos), twos), 1)
            }
            prod0 |= prod1 * twos;
            uint256 inverse = (3 * denominator) ^ 2;
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            inverse *= 2 - denominator * inverse; 
            result = prod0 * inverse;
            return result;
        }
    }
    function mulDiv(uint256 x, uint256 y, uint256 denominator, Rounding rounding) internal pure returns (uint256) {
        uint256 result = mulDiv(x, y, denominator);
        if (rounding == Rounding.Up && mulmod(x, y, denominator) > 0) {
            result += 1;
        }
        return result;
    }
    function sqrt(uint256 a) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 result = 1 << (log2(a) >> 1);
        unchecked {
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            result = (result + a / result) >> 1;
            return min(result, a / result);
        }
    }
    function sqrt(uint256 a, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = sqrt(a);
            return result + (rounding == Rounding.Up && result * result < a ? 1 : 0);
        }
    }
    function log2(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 128;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 64;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 32;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 16;
            }
            if (value >> 8 > 0) {
                value >>= 8;
                result += 8;
            }
            if (value >> 4 > 0) {
                value >>= 4;
                result += 4;
            }
            if (value >> 2 > 0) {
                value >>= 2;
                result += 2;
            }
            if (value >> 1 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log2(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log2(value);
            return result + (rounding == Rounding.Up && 1 << result < value ? 1 : 0);
        }
    }
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10 ** 64) {
                value /= 10 ** 64;
                result += 64;
            }
            if (value >= 10 ** 32) {
                value /= 10 ** 32;
                result += 32;
            }
            if (value >= 10 ** 16) {
                value /= 10 ** 16;
                result += 16;
            }
            if (value >= 10 ** 8) {
                value /= 10 ** 8;
                result += 8;
            }
            if (value >= 10 ** 4) {
                value /= 10 ** 4;
                result += 4;
            }
            if (value >= 10 ** 2) {
                value /= 10 ** 2;
                result += 2;
            }
            if (value >= 10 ** 1) {
                result += 1;
            }
        }
        return result;
    }
    function log10(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log10(value);
            return result + (rounding == Rounding.Up && 10 ** result < value ? 1 : 0);
        }
    }
    function log256(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >> 128 > 0) {
                value >>= 128;
                result += 16;
            }
            if (value >> 64 > 0) {
                value >>= 64;
                result += 8;
            }
            if (value >> 32 > 0) {
                value >>= 32;
                result += 4;
            }
            if (value >> 16 > 0) {
                value >>= 16;
                result += 2;
            }
            if (value >> 8 > 0) {
                result += 1;
            }
        }
        return result;
    }
    function log256(uint256 value, Rounding rounding) internal pure returns (uint256) {
        unchecked {
            uint256 result = log256(value);
            return result + (rounding == Rounding.Up && 1 << (result << 3) < value ? 1 : 0);
        }
    }
}
library SignedMathUpgradeable {
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }
    function average(int256 a, int256 b) internal pure returns (int256) {
        int256 x = (a & b) + ((a ^ b) >> 1);
        return x + (int256(uint256(x) >> 255) & (a ^ b));
    }
    function abs(int256 n) internal pure returns (uint256) {
        unchecked {
            return uint256(n >= 0 ? n : -n);
        }
    }
}
library StringsUpgradeable {
    bytes16 private constant _SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;
    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = MathUpgradeable.log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }
    function toString(int256 value) internal pure returns (string memory) {
        return string(abi.encodePacked(value < 0 ? "-" : "", toString(SignedMathUpgradeable.abs(value))));
    }
    function toHexString(uint256 value) internal pure returns (string memory) {
        unchecked {
            return toHexString(value, MathUpgradeable.log256(value) + 1);
        }
    }
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
    function equal(string memory a, string memory b) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }
}
abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
    }
    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}
contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;
    string private _name;
    string private _symbol;
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    function __ERC721_init(string memory name_, string memory symbol_) internal onlyInitializing {
        __ERC721_init_unchained(name_, symbol_);
    }
    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {
        _name = name_;
        _symbol = symbol_;
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }
    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: address zero is not a valid owner");
        return _balances[owner];
    }
    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _ownerOf(tokenId);
        require(owner != address(0), "ERC721: invalid token ID");
        return owner;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        _requireMinted(tokenId);
        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }
    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");
        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not token owner or approved for all"
        );
        _approve(to, tokenId);
    }
    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        _requireMinted(tokenId);
        return _tokenApprovals[tokenId];
    }
    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }
    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }
    function transferFrom(address from, address to, uint256 tokenId) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _safeTransfer(from, to, tokenId, data);
    }
    function _safeTransfer(address from, address to, uint256 tokenId, bytes memory data) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "ERC721: transfer to non ERC721Receiver implementer");
    }
    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }
    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }
    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }
    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
    function _safeMint(address to, uint256 tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }
    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");
        _beforeTokenTransfer(address(0), to, tokenId, 1);
        require(!_exists(tokenId), "ERC721: token already minted");
        unchecked {
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId, 1);
    }
    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId, 1);
        owner = ERC721Upgradeable.ownerOf(tokenId);
        delete _tokenApprovals[tokenId];
        unchecked {
            _balances[owner] -= 1;
        }
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId, 1);
    }
    function _transfer(address from, address to, uint256 tokenId) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        require(to != address(0), "ERC721: transfer to the zero address");
        _beforeTokenTransfer(from, to, tokenId, 1);
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer from incorrect owner");
        delete _tokenApprovals[tokenId];
        unchecked {
            _balances[from] -= 1;
            _balances[to] += 1;
        }
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId, 1);
    }
    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }
    function _setApprovalForAll(address owner, address operator, bool approved) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }
    function _requireMinted(uint256 tokenId) internal view virtual {
        require(_exists(tokenId), "ERC721: invalid token ID");
    }
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
    function _afterTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal virtual {}
    function __unsafe_increaseBalance(address account, uint256 amount) internal {
        _balances[account] += amount;
    }
    uint256[44] private __gap;
}
abstract contract ERC721BurnableUpgradeable is Initializable, ContextUpgradeable, ERC721Upgradeable {
    function __ERC721Burnable_init() internal onlyInitializing {
    }
    function __ERC721Burnable_init_unchained() internal onlyInitializing {
    }
    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
    uint256[50] private __gap;
}
interface INFTCollectionInitializer {
  function initialize(address payable _creator, string memory _name, string memory _symbol) external;
}
struct CallWithoutValue {
  address target;
  bytes callData;
}
error AddressLibrary_Proxy_Call_Did_Not_Return_A_Contract(address addressReturned);
library AddressLibrary {
  using AddressUpgradeable for address;
  using AddressUpgradeable for address payable;
  function callAndReturnContractAddress(
    address externalContract,
    bytes calldata callData
  ) internal returns (address payable contractAddress) {
    bytes memory returnData = externalContract.functionCall(callData);
    contractAddress = abi.decode(returnData, (address));
    if (!contractAddress.isContract()) {
      revert AddressLibrary_Proxy_Call_Did_Not_Return_A_Contract(contractAddress);
    }
  }
  function callAndReturnContractAddress(
    CallWithoutValue calldata call
  ) internal returns (address payable contractAddress) {
    contractAddress = callAndReturnContractAddress(call.target, call.callData);
  }
}
interface IGetFees {
  function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory recipients);
  function getFeeBps(uint256 tokenId) external view returns (uint256[] memory royaltiesInBasisPoints);
}
interface IGetRoyalties {
  function getRoyalties(
    uint256 tokenId
  ) external view returns (address payable[] memory recipients, uint256[] memory royaltiesInBasisPoints);
}
interface IRoyaltyInfo {
  function royaltyInfo(
    uint256 tokenId,
    uint256 salePrice
  ) external view returns (address receiver, uint256 royaltyAmount);
}
interface ITokenCreator {
  function tokenCreator(uint256 tokenId) external view returns (address payable creator);
}
uint256 constant BASIS_POINTS = 10_000;
bytes32 constant DEFAULT_ADMIN_ROLE = 0x00;
uint256 constant MAX_EXHIBITION_TAKE_RATE = 5_000;
uint256 constant MAX_ROYALTY_RECIPIENTS = 5;
uint96 constant ROYALTY_IN_BASIS_POINTS = 1_000;
uint96 constant BUY_REFERRER_IN_BASIS_POINTS = 100;
uint256 constant ROYALTY_RATIO = BASIS_POINTS / ROYALTY_IN_BASIS_POINTS;
uint256 constant BUY_REFERRER_RATIO = BASIS_POINTS / BUY_REFERRER_IN_BASIS_POINTS;
uint256 constant READ_ONLY_GAS_LIMIT = 40_000;
uint256 constant SEND_VALUE_GAS_LIMIT_MULTIPLE_RECIPIENTS = 210_000;
uint256 constant SEND_VALUE_GAS_LIMIT_SINGLE_RECIPIENT = 20_000;
string constant NFT_COLLECTION_TYPE = "NFT Collection";
string constant NFT_DROP_COLLECTION_TYPE = "NFT Drop Collection";
string constant NFT_TIMED_EDITION_COLLECTION_TYPE = "NFT Timed Edition Collection";
string constant NFT_LIMITED_EDITION_COLLECTION_TYPE = "NFT Limited Edition Collection";
uint256 constant MAX_SCHEDULED_TIME_IN_THE_FUTURE = 365 days * 2;
uint256 constant MIN_PERCENT_INCREMENT_DENOMINATOR = BASIS_POINTS / 1_000;
uint256 constant EDITION_PROTOCOL_FEE_IN_BASIS_POINTS = 500;
bytes32 constant timedEditionTypeHash = 0xee2afa3f960e108aca17013728aafa363a0f4485661d9b6f41c6b4ddb55008ee;
bytes32 constant limitedEditionTypeHash = 0x7df1f68d01ab1a6ee0448a4c3fbda832177331ff72c471b12b0051c96742eef5;
abstract contract CollectionRoyalties is IGetRoyalties, IGetFees, IRoyaltyInfo, ITokenCreator, ERC165Upgradeable {
  function getFeeRecipients(uint256 tokenId) external view returns (address payable[] memory recipients) {
    recipients = new address payable[](1);
    recipients[0] = getTokenCreatorPaymentAddress(tokenId);
  }
  function getFeeBps(uint256 ) external pure returns (uint256[] memory royaltiesInBasisPoints) {
    royaltiesInBasisPoints = new uint256[](1);
    royaltiesInBasisPoints[0] = ROYALTY_IN_BASIS_POINTS;
  }
  function getRoyalties(
    uint256 tokenId
  ) external view returns (address payable[] memory recipients, uint256[] memory royaltiesInBasisPoints) {
    recipients = new address payable[](1);
    recipients[0] = getTokenCreatorPaymentAddress(tokenId);
    royaltiesInBasisPoints = new uint256[](1);
    royaltiesInBasisPoints[0] = ROYALTY_IN_BASIS_POINTS;
  }
  function getTokenCreatorPaymentAddress(
    uint256 tokenId
  ) public view virtual returns (address payable creatorPaymentAddress);
  function royaltyInfo(
    uint256 tokenId,
    uint256 salePrice
  ) external view returns (address receiver, uint256 royaltyAmount) {
    receiver = getTokenCreatorPaymentAddress(tokenId);
    unchecked {
      royaltyAmount = salePrice / ROYALTY_RATIO;
    }
  }
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool interfaceSupported) {
    interfaceSupported = (interfaceId == type(IRoyaltyInfo).interfaceId ||
      interfaceId == type(ITokenCreator).interfaceId ||
      interfaceId == type(IGetRoyalties).interfaceId ||
      interfaceId == type(IGetFees).interfaceId ||
      super.supportsInterface(interfaceId));
  }
}
library StorageSlot {
    struct AddressSlot {
        address value;
    }
    struct BooleanSlot {
        bool value;
    }
    struct Bytes32Slot {
        bytes32 value;
    }
    struct Uint256Slot {
        uint256 value;
    }
    struct StringSlot {
        string value;
    }
    struct BytesSlot {
        bytes value;
    }
    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(bytes32 slot) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getStringSlot(string storage store) internal pure returns (StringSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
    function getBytesSlot(bytes32 slot) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := slot
        }
    }
    function getBytesSlot(bytes storage store) internal pure returns (BytesSlot storage r) {
        assembly {
            r.slot := store.slot
        }
    }
}
type ShortString is bytes32;
library ShortStrings {
    bytes32 private constant _FALLBACK_SENTINEL = 0x00000000000000000000000000000000000000000000000000000000000000FF;
    error StringTooLong(string str);
    error InvalidShortString();
    function toShortString(string memory str) internal pure returns (ShortString) {
        bytes memory bstr = bytes(str);
        if (bstr.length > 31) {
            revert StringTooLong(str);
        }
        return ShortString.wrap(bytes32(uint256(bytes32(bstr)) | bstr.length));
    }
    function toString(ShortString sstr) internal pure returns (string memory) {
        uint256 len = byteLength(sstr);
        string memory str = new string(32);
        assembly {
            mstore(str, len)
            mstore(add(str, 0x20), sstr)
        }
        return str;
    }
    function byteLength(ShortString sstr) internal pure returns (uint256) {
        uint256 result = uint256(ShortString.unwrap(sstr)) & 0xFF;
        if (result > 31) {
            revert InvalidShortString();
        }
        return result;
    }
    function toShortStringWithFallback(string memory value, string storage store) internal returns (ShortString) {
        if (bytes(value).length < 32) {
            return toShortString(value);
        } else {
            StorageSlot.getStringSlot(store).value = value;
            return ShortString.wrap(_FALLBACK_SENTINEL);
        }
    }
    function toStringWithFallback(ShortString value, string storage store) internal pure returns (string memory) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return toString(value);
        } else {
            return store;
        }
    }
    function byteLengthWithFallback(ShortString value, string storage store) internal view returns (uint256) {
        if (ShortString.unwrap(value) != _FALLBACK_SENTINEL) {
            return byteLength(value);
        } else {
            return bytes(store).length;
        }
    }
}
interface INFTCollectionType {
  function getNFTCollectionType() external view returns (string memory collectionType);
}
abstract contract NFTCollectionType is INFTCollectionType, ERC165Upgradeable {
  using ShortStrings for string;
  using ShortStrings for ShortString;
  ShortString private immutable _collectionTypeName;
  constructor(string memory collectionTypeName) {
    _collectionTypeName = collectionTypeName.toShortString();
  }
  function getNFTCollectionType() external view returns (string memory collectionType) {
    collectionType = _collectionTypeName.toString();
  }
  function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool interfaceSupported) {
    interfaceSupported = interfaceId == type(INFTCollectionType).interfaceId || super.supportsInterface(interfaceId);
  }
}
error SequentialMintCollection_Caller_Is_Not_Owner(address owner);
error SequentialMintCollection_Minted_NFTs_Must_Be_Burned_First(uint256 totalSupply);
abstract contract SequentialMintCollection is ITokenCreator, ERC721BurnableUpgradeable {
  address payable public owner;
  uint32 public latestTokenId;
  uint32 private burnCounter;
  event SelfDestruct(address indexed admin);
  modifier onlyOwner() {
    if (msg.sender != owner) {
      revert SequentialMintCollection_Caller_Is_Not_Owner(owner);
    }
    _;
  }
  function _initializeSequentialMintCollection(address payable _creator) internal {
    owner = _creator;
  }
  function _selfDestruct() internal {
    if (totalSupply() != 0) {
      revert SequentialMintCollection_Minted_NFTs_Must_Be_Burned_First(totalSupply());
    }
    emit SelfDestruct(msg.sender);
    selfdestruct(payable(msg.sender));
  }
  function _burn(uint256 tokenId) internal virtual override {
    unchecked {
      ++burnCounter;
    }
    super._burn(tokenId);
  }
  function tokenCreator(uint256 ) external view returns (address payable creator) {
    creator = owner;
  }
  function totalSupply() public view returns (uint256 supply) {
    unchecked {
      supply = latestTokenId - burnCounter;
    }
  }
}
error TokenLimitedCollection_Max_Token_Id_May_Not_Be_Cleared(uint256 currentMaxTokenId);
error TokenLimitedCollection_Max_Token_Id_May_Not_Increase(uint256 currentMaxTokenId);
error TokenLimitedCollection_Max_Token_Id_Must_Be_Greater_Than_Current_Minted_Count(uint256 currentMintedCount);
error TokenLimitedCollection_Max_Token_Id_Must_Not_Be_Zero();
abstract contract TokenLimitedCollection is SequentialMintCollection {
  uint32 public maxTokenId;
  event MaxTokenIdUpdated(uint256 indexed maxTokenId);
  function _initializeTokenLimitedCollection(uint32 _maxTokenId) internal {
    if (_maxTokenId == 0) {
      revert TokenLimitedCollection_Max_Token_Id_Must_Not_Be_Zero();
    }
    maxTokenId = _maxTokenId;
  }
  function _updateMaxTokenId(uint32 _maxTokenId) internal {
    if (_maxTokenId == 0) {
      revert TokenLimitedCollection_Max_Token_Id_May_Not_Be_Cleared(maxTokenId);
    }
    if (maxTokenId != 0 && _maxTokenId >= maxTokenId) {
      revert TokenLimitedCollection_Max_Token_Id_May_Not_Increase(maxTokenId);
    }
    if (latestTokenId > _maxTokenId) {
      revert TokenLimitedCollection_Max_Token_Id_Must_Be_Greater_Than_Current_Minted_Count(latestTokenId);
    }
    maxTokenId = _maxTokenId;
    emit MaxTokenIdUpdated(_maxTokenId);
  }
}
error ContractFactory_Only_Callable_By_Factory_Contract(address contractFactory);
error ContractFactory_Factory_Is_Not_A_Contract();
abstract contract ContractFactory {
  using AddressUpgradeable for address;
  address public immutable contractFactory;
  modifier onlyContractFactory() {
    if (msg.sender != contractFactory) {
      revert ContractFactory_Only_Callable_By_Factory_Contract(contractFactory);
    }
    _;
  }
  constructor(address _contractFactory) {
    if (!_contractFactory.isContract()) {
      revert ContractFactory_Factory_Is_Not_A_Contract();
    }
    contractFactory = _contractFactory;
  }
}
error NFTCollection_Max_Token_Id_Has_Already_Been_Minted(uint256 maxTokenId);
error NFTCollection_Token_CID_Already_Minted();
error NFTCollection_Token_CID_Required();
error NFTCollection_Token_Creator_Payment_Address_Required();
contract NFTCollection is
  INFTCollectionInitializer,
  ContractFactory,
  Initializable,
  ERC165Upgradeable,
  ERC721Upgradeable,
  ERC721BurnableUpgradeable,
  NFTCollectionType,
  SequentialMintCollection,
  TokenLimitedCollection,
  CollectionRoyalties
{
  using AddressLibrary for address;
  using AddressUpgradeable for address;
  string private baseURI_;
  mapping(string => uint256) private cidToMinted;
  mapping(uint256 => address payable) private tokenIdToCreatorPaymentAddress;
  mapping(uint256 => string) private _tokenCIDs;
  event BaseURIUpdated(string baseURI);
  event Minted(address indexed creator, uint256 indexed tokenId, string indexed indexedTokenCID, string tokenCID);
  event TokenCreatorPaymentAddressSet(
    address indexed fromPaymentAddress,
    address indexed toPaymentAddress,
    uint256 indexed tokenId
  );
  constructor(address _contractFactory) ContractFactory(_contractFactory) NFTCollectionType(NFT_COLLECTION_TYPE) {
  }
  function initialize(
    address payable _creator,
    string calldata _name,
    string calldata _symbol
  ) external initializer onlyContractFactory {
    __ERC721_init(_name, _symbol);
    _initializeSequentialMintCollection(_creator);
  }
  function mint(string calldata tokenCID) external returns (uint256 tokenId) {
    tokenId = _mint(tokenCID);
  }
  function mintAndApprove(string calldata tokenCID, address operator) external returns (uint256 tokenId) {
    tokenId = _mint(tokenCID);
    setApprovalForAll(operator, true);
  }
  function mintWithCreatorPaymentAddress(
    string calldata tokenCID,
    address payable tokenCreatorPaymentAddress
  ) public returns (uint256 tokenId) {
    if (tokenCreatorPaymentAddress == address(0)) {
      revert NFTCollection_Token_Creator_Payment_Address_Required();
    }
    tokenId = _mint(tokenCID);
    tokenIdToCreatorPaymentAddress[tokenId] = tokenCreatorPaymentAddress;
    emit TokenCreatorPaymentAddressSet(address(0), tokenCreatorPaymentAddress, tokenId);
  }
  function mintWithCreatorPaymentAddressAndApprove(
    string calldata tokenCID,
    address payable tokenCreatorPaymentAddress,
    address operator
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentAddress(tokenCID, tokenCreatorPaymentAddress);
    setApprovalForAll(operator, true);
  }
  function mintWithCreatorPaymentFactory(
    string calldata tokenCID,
    address paymentAddressFactory,
    bytes calldata paymentAddressCall
  ) public returns (uint256 tokenId) {
    address payable tokenCreatorPaymentAddress = paymentAddressFactory.callAndReturnContractAddress(paymentAddressCall);
    tokenId = mintWithCreatorPaymentAddress(tokenCID, tokenCreatorPaymentAddress);
  }
  function mintWithCreatorPaymentFactoryAndApprove(
    string calldata tokenCID,
    address paymentAddressFactory,
    bytes calldata paymentAddressCall,
    address operator
  ) external returns (uint256 tokenId) {
    tokenId = mintWithCreatorPaymentFactory(tokenCID, paymentAddressFactory, paymentAddressCall);
    setApprovalForAll(operator, true);
  }
  function selfDestruct() external onlyOwner {
    _selfDestruct();
  }
  function updateBaseURI(string calldata baseURIOverride) external onlyOwner {
    baseURI_ = baseURIOverride;
    emit BaseURIUpdated(baseURIOverride);
  }
  function updateMaxTokenId(uint32 _maxTokenId) external onlyOwner {
    _updateMaxTokenId(_maxTokenId);
  }
  function _burn(uint256 tokenId) internal override(ERC721Upgradeable, SequentialMintCollection) onlyOwner {
    delete cidToMinted[_tokenCIDs[tokenId]];
    delete tokenIdToCreatorPaymentAddress[tokenId];
    delete _tokenCIDs[tokenId];
    super._burn(tokenId);
  }
  function _mint(string calldata tokenCID) private onlyOwner returns (uint256 tokenId) {
    if (bytes(tokenCID).length == 0) {
      revert NFTCollection_Token_CID_Required();
    }
    if (cidToMinted[tokenCID] != 0) {
      revert NFTCollection_Token_CID_Already_Minted();
    }
    tokenId = ++latestTokenId;
    if (maxTokenId != 0 && tokenId > maxTokenId) {
      revert NFTCollection_Max_Token_Id_Has_Already_Been_Minted(maxTokenId);
    }
    cidToMinted[tokenCID] = 1;
    _tokenCIDs[tokenId] = tokenCID;
    _safeMint(msg.sender, tokenId);
    emit Minted(msg.sender, tokenId, tokenCID, tokenCID);
  }
  function baseURI() external view returns (string memory uri) {
    uri = _baseURI();
  }
  function getHasMintedCID(string calldata tokenCID) external view returns (bool hasBeenMinted) {
    hasBeenMinted = cidToMinted[tokenCID] != 0;
  }
  function getTokenCreatorPaymentAddress(
    uint256 tokenId
  ) public view override returns (address payable creatorPaymentAddress) {
    creatorPaymentAddress = tokenIdToCreatorPaymentAddress[tokenId];
    if (creatorPaymentAddress == address(0)) {
      creatorPaymentAddress = owner;
    }
  }
  function supportsInterface(
    bytes4 interfaceId
  )
    public
    view
    override(ERC165Upgradeable, ERC721Upgradeable, NFTCollectionType, CollectionRoyalties)
    returns (bool interfaceSupported)
  {
    interfaceSupported = super.supportsInterface(interfaceId);
  }
  function tokenURI(uint256 tokenId) public view override returns (string memory uri) {
    _requireMinted(tokenId);
    uri = string.concat(_baseURI(), _tokenCIDs[tokenId]);
  }
  function _baseURI() internal view override returns (string memory uri) {
    uri = baseURI_;
    if (bytes(uri).length == 0) {
      uri = "ipfs://";
    }
  }
}
