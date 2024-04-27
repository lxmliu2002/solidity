/**
 *Submitted for verification at Etherscan.io on 2022-11-04
*/

// File: contracts\interfaces\ICurveConvex.sol

// SPDX-License-Identifier: MIT
pragma solidity 0.8.10;
interface ICurveConvex {
   function earmarkRewards(uint256 _pid) external returns(bool);
   function earmarkFees() external returns(bool);
   function poolInfo(uint256 _pid) external returns(address _lptoken, address _token, address _gauge, address _crvRewards, address _stash, bool _shutdown);
}
interface IConvexWrapperV2{
   struct EarnedData {
        address token;
        uint256 amount;
    }
  function collateralVault() external view returns(address vault);
  function convexPoolId() external view returns(uint256 _poolId);
  function balanceOf(address _account) external view returns(uint256);
  function totalBalanceOf(address _account) external view returns(uint256);
  function deposit(uint256 _amount, address _to) external;
  function stake(uint256 _amount, address _to) external;
  function withdraw(uint256 _amount) external;
  function withdrawAndUnwrap(uint256 _amount) external;
  function getReward(address _account) external;
  function getReward(address _account, address _forwardTo) external;
  function rewardLength() external view returns(uint256);
  function earned(address _account) external returns(EarnedData[] memory claimable);
  function earnedView(address _account) external view returns(EarnedData[] memory claimable);
  function setVault(address _vault) external;
  function user_checkpoint(address[2] calldata _accounts) external returns(bool);
}
interface IProxyVault {
    enum VaultType{
        Erc20Basic,
        UniV3,
        Convex,
        Erc20Joint
    }
    function initialize(address _owner, address _stakingAddress, address _stakingToken, address _rewardsAddress) external;
    function usingProxy() external returns(address);
    function owner() external returns(address);
    function stakingAddress() external returns(address);
    function rewards() external returns(address);
    function getReward() external;
    function getReward(bool _claim) external;
    function getReward(bool _claim, address[] calldata _rewardTokenList) external;
    function earned() external view returns (address[] memory token_addresses, uint256[] memory total_earned);
}
interface IFeeRegistry{
    function cvxfxsIncentive() external view returns(uint256);
    function cvxIncentive() external view returns(uint256);
    function platformIncentive() external view returns(uint256);
    function totalFees() external view returns(uint256);
    function maxFees() external view returns(uint256);
    function feeDeposit() external view returns(address);
    function getFeeDepositor(address _from) external view returns(address);
}
interface IFraxFarmBase{
    function totalLiquidityLocked() external view returns (uint256);
    function lockedLiquidityOf(address account) external view returns (uint256);
    function toggleValidVeFXSProxy(address proxy_address) external;
    function proxyToggleStaker(address staker_address) external;
    function stakerSetVeFXSProxy(address proxy_address) external;
    function getReward(address destination_address) external returns (uint256[] memory);
}
interface IRewards{
    struct EarnedData {
        address token;
        uint256 amount;
    }
    function initialize(uint256 _pid, bool _startActive) external;
    function addReward(address _rewardsToken, address _distributor) external;
    function approveRewardDistributor(
        address _rewardsToken,
        address _distributor,
        bool _approved
    ) external;
    function deposit(address _owner, uint256 _amount) external;
    function withdraw(address _owner, uint256 _amount) external;
    function getReward(address _forward) external;
    function notifyRewardAmount(address _rewardsToken, uint256 _reward) external;
    function balanceOf(address account) external view returns (uint256);
    function claimableRewards(address _account) external view returns(EarnedData[] memory userRewards);
    function rewardTokens(uint256 _rid) external view returns (address);
    function rewardTokenLength() external view returns(uint256);
    function active() external view returns(bool);
}
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
        (bool success, ) = recipient.call{value: amount}("./StakingProxyConvex.sol");
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
library SafeERC20 {
    using Address for address;
    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
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
contract StakingProxyBase is IProxyVault{
    using SafeERC20 for IERC20;
    address public constant fxs = address(0x3432B6A60D23Ca0dFCa7761B7ab56459D9C964D0);
    address public constant vefxsProxy = address(0x59CFCD384746ec3035299D90782Be065e466800B);
    address public constant feeRegistry = address(0xC9aCB83ADa68413a6Aa57007BC720EE2E2b3C46D); 
    address public owner; 
    address public stakingAddress; 
    address public stakingToken; 
    address public rewards; 
    address public usingProxy; 
    uint256 public constant FEE_DENOMINATOR = 10000;
    constructor() {
    }
    function vaultType() external virtual pure returns(VaultType){
        return VaultType.Erc20Basic;
    }
    function vaultVersion() external virtual pure returns(uint256){
        return 1;
    }
    
    
    function initialize(address _owner, address _stakingAddress, address _stakingToken, address _rewardsAddress) external virtual{
    }
    function changeRewards(address _rewardsAddress) external onlyAdmin{
        if(IRewards(rewards).active()){
            uint256 bal = IRewards(rewards).balanceOf(address(this));
            if(bal > 0){
                IRewards(rewards).withdraw(owner, bal);
            }
            IRewards(rewards).getReward(owner);
        }
        rewards = _rewardsAddress;
        _checkpointRewards();
    }
    function checkpointRewards() external onlyAdmin{
        _checkpointFarm();
    }
    
    function setVeFXSProxy(address _proxy) external virtual onlyAdmin{
        _setVeFXSProxy(_proxy);
    }
    
    function getReward() external virtual{}
    function getReward(bool _claim) external virtual{}
    function getReward(bool _claim, address[] calldata _rewardTokenList) external virtual{}
    function earned() external view virtual returns (address[] memory token_addresses, uint256[] memory total_earned){}
    function _checkpointRewards() internal{
        if(IRewards(rewards).active()){
            uint256 userLiq = IFraxFarmBase(stakingAddress).lockedLiquidityOf(address(this));
            uint256 bal = IRewards(rewards).balanceOf(address(this));
            if(userLiq >= bal){
                IRewards(rewards).deposit(owner, userLiq - bal);
            }else{
                IRewards(rewards).withdraw(owner, bal - userLiq);
            }
        }
    }
    function _processFxs() internal{
        uint256 totalFees = IFeeRegistry(feeRegistry).totalFees();
        uint256 fxsBalance = IERC20(fxs).balanceOf(address(this));
        uint256 sendAmount = fxsBalance * totalFees / FEE_DENOMINATOR;
        if(sendAmount > 0){
            IERC20(fxs).transfer(IFeeRegistry(feeRegistry).getFeeDepositor(usingProxy), sendAmount);
        }
        sendAmount = IERC20(fxs).balanceOf(address(this));
        if(sendAmount > 0){
            IERC20(fxs).transfer(owner, sendAmount);
        }
    }
    function _processExtraRewards() internal{
        if(IRewards(rewards).active()){
            uint256 bal = IRewards(rewards).balanceOf(address(this));
            uint256 userLiq = IFraxFarmBase(stakingAddress).lockedLiquidityOf(address(this));
            if(bal == 0 && userLiq > 0){
                IRewards(rewards).deposit(owner,userLiq);
            }
            IRewards(rewards).getReward(owner);
        }
    }
    function _transferTokens(address[] memory _tokens) internal{
        for(uint256 i = 0; i < _tokens.length; i++){
            if(_tokens[i] != fxs){
                uint256 bal = IERC20(_tokens[i]).balanceOf(address(this));
                if(bal > 0){
                    IERC20(_tokens[i]).safeTransfer(owner, bal);
                }
            }
        }
    }
}
interface IFraxFarmERC20 {
    struct LockedStake {
        bytes32 kek_id;
        uint256 start_timestamp;
        uint256 liquidity;
        uint256 ending_timestamp;
        uint256 lock_multiplier; 
    }
    function owner() external view returns (address);
    function stakingToken() external view returns (address);
    function fraxPerLPToken() external view returns (uint256);
    function calcCurCombinedWeight(address account) external view
        returns (
            uint256 old_combined_weight,
            uint256 new_vefxs_multiplier,
            uint256 new_combined_weight
        );
    function lockedStakesOf(address account) external view returns (LockedStake[] memory);
    function lockedStakesOfLength(address account) external view returns (uint256);
    function lockAdditional(bytes32 kek_id, uint256 addl_liq) external;
    function lockLonger(bytes32 kek_id, uint256 new_ending_ts) external;
    function stakeLocked(uint256 liquidity, uint256 secs) external returns (bytes32);
    function withdrawLocked(bytes32 kek_id, address destination_address) external returns (uint256);
    function periodFinish() external view returns (uint256);
    function getAllRewardTokens() external view returns (address[] memory);
    function earned(address account) external view returns (uint256[] memory new_earned);
    function totalLiquidityLocked() external view returns (uint256);
    function lockedLiquidityOf(address account) external view returns (uint256);
    function totalCombinedWeight() external view returns (uint256);
    function combinedWeightOf(address account) external view returns (uint256);
    function lockMultiplier(uint256 secs) external view returns (uint256);
    function rewardRates(uint256 token_idx) external view returns (uint256 rwd_rate);
    function userStakedFrax(address account) external view returns (uint256);
    function proxyStakedFrax(address proxy_address) external view returns (uint256);
    function maxLPForMaxBoost(address account) external view returns (uint256);
    function minVeFXSForMaxBoost(address account) external view returns (uint256);
    function minVeFXSForMaxBoostProxy(address proxy_address) external view returns (uint256);
    function veFXSMultiplier(address account) external view returns (uint256 vefxs_multiplier);
    function toggleValidVeFXSProxy(address proxy_address) external;
    function proxyToggleStaker(address staker_address) external;
    function stakerSetVeFXSProxy(address proxy_address) external;
    function getReward(address destination_address) external returns (uint256[] memory);
    function vefxs_max_multiplier() external view returns(uint256);
    function vefxs_boost_scale_factor() external view returns(uint256);
    function vefxs_per_frax_for_max_boost() external view returns(uint256);
    function getProxyFor(address addr) external view returns (address);
    function sync() external;
}
abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;
    constructor() {
        _status = _NOT_ENTERED;
    }
    
}
contract StakingProxyConvex is StakingProxyBase, ReentrancyGuard{
    using SafeERC20 for IERC20;
    address public constant poolRegistry = address(0x7413bFC877B5573E29f964d572f421554d8EDF86);
    address public constant convexCurveBooster = address(0xF403C135812408BFbE8713b5A23a04b3D48AAE31);
    address public constant crv = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public constant cvx = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public curveLpToken;
    address public convexDepositToken;
    constructor() {
    }
    function vaultType() external pure override returns(VaultType){
        return VaultType.Convex;
    }
    function vaultVersion() external pure override returns(uint256){
        return 4;
    }
    function initialize(address _owner, address _stakingAddress, address _stakingToken, address _rewardsAddress) external override{
        require(owner == address(0),"already init");
        owner = _owner;
        stakingAddress = _stakingAddress;
        stakingToken = _stakingToken;
        rewards = _rewardsAddress;
        (address _lptoken, address _token,,, , ) = ICurveConvex(convexCurveBooster).poolInfo(IConvexWrapperV2(_stakingToken).convexPoolId());
        curveLpToken = _lptoken;
        convexDepositToken = _token;
        IERC20(_stakingToken).approve(_stakingAddress, type(uint256).max);
        IERC20(_lptoken).approve(_stakingToken, type(uint256).max);
        IERC20(_token).approve(_stakingToken, type(uint256).max);
    }
    function stakeLockedCurveLp(uint256 _liquidity, uint256 _secs) external onlyOwner nonReentrant returns (bytes32 kek_id){
        if(_liquidity > 0){
            IERC20(curveLpToken).safeTransferFrom(msg.sender, address(this), _liquidity);
            IConvexWrapperV2(stakingToken).deposit(_liquidity, address(this));
            kek_id = IFraxFarmERC20(stakingAddress).stakeLocked(_liquidity, _secs);
        }
        _checkpointRewards();
    }
    function stakeLockedConvexToken(uint256 _liquidity, uint256 _secs) external onlyOwner nonReentrant returns (bytes32 kek_id){
        if(_liquidity > 0){
            IERC20(convexDepositToken).safeTransferFrom(msg.sender, address(this), _liquidity);
            IConvexWrapperV2(stakingToken).stake(_liquidity, address(this));
            kek_id = IFraxFarmERC20(stakingAddress).stakeLocked(_liquidity, _secs);
        }
        _checkpointRewards();
    }
    function stakeLocked(uint256 _liquidity, uint256 _secs) external onlyOwner nonReentrant returns (bytes32 kek_id){
        if(_liquidity > 0){
            IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), _liquidity);
            kek_id = IFraxFarmERC20(stakingAddress).stakeLocked(_liquidity, _secs);
        }
        _checkpointRewards();
    }
    function lockAdditional(bytes32 _kek_id, uint256 _addl_liq) external onlyOwner nonReentrant{
        if(_addl_liq > 0){
            IERC20(stakingToken).safeTransferFrom(msg.sender, address(this), _addl_liq);
            IFraxFarmERC20(stakingAddress).lockAdditional(_kek_id, _addl_liq);
        }
        _checkpointRewards();
    }
    function lockAdditionalCurveLp(bytes32 _kek_id, uint256 _addl_liq) external onlyOwner nonReentrant{
        if(_addl_liq > 0){
            IERC20(curveLpToken).safeTransferFrom(msg.sender, address(this), _addl_liq);
            IConvexWrapperV2(stakingToken).deposit(_addl_liq, address(this));
            IFraxFarmERC20(stakingAddress).lockAdditional(_kek_id, _addl_liq);
        }
        _checkpointRewards();
    }
    function lockAdditionalConvexToken(bytes32 _kek_id, uint256 _addl_liq) external onlyOwner nonReentrant{
        if(_addl_liq > 0){
            IERC20(convexDepositToken).safeTransferFrom(msg.sender, address(this), _addl_liq);
            IConvexWrapperV2(stakingToken).stake(_addl_liq, address(this));
            IFraxFarmERC20(stakingAddress).lockAdditional(_kek_id, _addl_liq);
        }
        _checkpointRewards();
    }
    function lockLonger(bytes32 _kek_id, uint256 new_ending_ts) external onlyOwner nonReentrant{
        IFraxFarmERC20(stakingAddress).lockLonger(_kek_id, new_ending_ts);
        _checkpointRewards();
    }
    function withdrawLocked(bytes32 _kek_id) external onlyOwner nonReentrant{        
        IFraxFarmERC20(stakingAddress).withdrawLocked(_kek_id, msg.sender);
        _checkpointRewards();
    }
    function withdrawLockedAndUnwrap(bytes32 _kek_id) external onlyOwner nonReentrant{
        IFraxFarmERC20(stakingAddress).withdrawLocked(_kek_id, address(this));
        IConvexWrapperV2(stakingToken).withdrawAndUnwrap(IERC20(stakingToken).balanceOf(address(this)));
        IERC20(curveLpToken).transfer(owner,IERC20(curveLpToken).balanceOf(address(this)));
        _checkpointRewards();
    }
    function earned() external view override returns (address[] memory token_addresses, uint256[] memory total_earned) {
        address[] memory rewardTokens = IFraxFarmERC20(stakingAddress).getAllRewardTokens();
        uint256[] memory stakedearned = IFraxFarmERC20(stakingAddress).earned(address(this));
        IConvexWrapperV2.EarnedData[] memory convexrewards = IConvexWrapperV2(stakingToken).earnedView(address(this));
        uint256 extraRewardsLength = IRewards(rewards).rewardTokenLength();
        token_addresses = new address[](rewardTokens.length + extraRewardsLength + convexrewards.length);
        total_earned = new uint256[](rewardTokens.length + extraRewardsLength + convexrewards.length);
        for(uint256 i = 0; i < rewardTokens.length; i++){
            token_addresses[i] = rewardTokens[i];
            total_earned[i] = stakedearned[i] + IERC20(rewardTokens[i]).balanceOf(address(this));
        }
        IRewards.EarnedData[] memory extraRewards = IRewards(rewards).claimableRewards(address(this));
        for(uint256 i = 0; i < extraRewards.length; i++){
            token_addresses[i+rewardTokens.length] = extraRewards[i].token;
            total_earned[i+rewardTokens.length] = extraRewards[i].amount;
        }
        for(uint256 i = 0; i < convexrewards.length; i++){
            token_addresses[i+rewardTokens.length+extraRewardsLength] = convexrewards[i].token;
            total_earned[i+rewardTokens.length+extraRewardsLength] = convexrewards[i].amount;
        }
    }
    function getReward() external override{
        getReward(true);
    }
    function getReward(bool _claim) public override{
        if(_claim){
            IFraxFarmERC20(stakingAddress).getReward(address(this));
            IConvexWrapperV2(stakingToken).getReward(address(this),owner);
            uint256 b = IERC20(crv).balanceOf(address(this));
            if(b > 0){
                IERC20(crv).safeTransfer(owner, b);
            }
            b = IERC20(cvx).balanceOf(address(this));
            if(b > 0){
                IERC20(cvx).safeTransfer(owner, b);
            }
        }
        _processFxs();
        address[] memory rewardTokens = IFraxFarmERC20(stakingAddress).getAllRewardTokens();
        _transferTokens(rewardTokens);
        _processExtraRewards();
    }
    function getReward(bool _claim, address[] calldata _rewardTokenList) external override{
        if(_claim){
            IFraxFarmERC20(stakingAddress).getReward(address(this));
            IConvexWrapperV2(stakingToken).getReward(address(this),owner);
        }
        _processFxs();
        _transferTokens(_rewardTokenList);
        _processExtraRewards();
    }
}
