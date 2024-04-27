// Telegram: https://t.me/blockhub_portal
// Twitter:  https://twitter.com/blockhub_social
// Website:  https://www.blockhub.pro/
//
// Step into a New Era of Digital Expression
//
// SPDX-License-Identifier: MIT

pragma solidity 0.8.12;
abstract contract Context {
    
    
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
interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 private _totalSupply;
    string private _name;
    string private _symbol;
    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }
    function name() public view virtual override returns (string memory) {
        return _name;
    }
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        return true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        _beforeTokenTransfer(sender, recipient, amount);
        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    
    
    
    
}
library Address{
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}
abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _setOwner(_msgSender());
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }
    
}
interface IFactory{
        function createPair(address tokenA, address tokenB) external returns (address pair);
}
interface IRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline) external;
}
contract BlockHub is ERC20, Ownable{
    using Address for address payable;
    IRouter public router;
    address public pair;
    bool private swapping;
    bool public swapEnabled;
    bool public tradingEnabled;
    uint256 public genesis_block;
    uint256 public deadblocks = 0;
    uint256 public swapThreshold = 10_000 * 10e18;
    uint256 public maxTxAmount = 2_000_000 * 10**18;
    uint256 public maxWalletAmount = 2_000_000 * 10**18;
    address public marketingWallet = 0xC460622c115537f05137C407Ad17b06bb115bE8b;
    address public devWallet = 0xe2Ea4Ceb5f8608f2956ED7ca13C7301C29431b8E;
    struct Taxes {
        uint256 marketing;
        uint256 liquidity; 
        uint256 dev;
    }
    Taxes public taxes = Taxes(23,0,9);
    Taxes public sellTaxes = Taxes(19,0,6);
    uint256 public totTax = 32;
    uint256 public totSellTax = 25;
    mapping (address => bool) public excludedFromFees;
    mapping (address => bool) private isBot;
    modifier inSwap() {
        if (!swapping) {
            swapping = true;
            _;
            swapping = false;
        }
    }
    constructor() ERC20("BlockHub", "HUB") {
        _mint(msg.sender, 1e8 * 10 ** decimals());
        excludedFromFees[msg.sender] = true;
        IRouter _router = IRouter(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        address _pair = IFactory(_router.factory())
            .createPair(address(this), _router.WETH());
        router = _router;
        pair = _pair;
        excludedFromFees[address(this)] = true;
        excludedFromFees[marketingWallet] = true;
        excludedFromFees[devWallet] = true;
    }
    function _transfer(address sender, address recipient, uint256 amount) internal override {
        require(amount > 0, "Transfer amount must be greater than zero");
        require(!isBot[sender] && !isBot[recipient], "You can't transfer tokens");
        if(!excludedFromFees[sender] && !excludedFromFees[recipient] && !swapping){
            require(tradingEnabled, "Trading not active yet");
            if(genesis_block + deadblocks > block.number){
                if(recipient != pair) isBot[recipient] = true;
                if(sender != pair) isBot[sender] = true;
            }
            require(amount <= maxTxAmount, "You are exceeding maxTxAmount");
            if(recipient != pair){
                require(balanceOf(recipient) + amount <= maxWalletAmount, "You are exceeding maxWalletAmount");
            }
        }
        uint256 fee;
        if (swapping || excludedFromFees[sender] || excludedFromFees[recipient]) fee = 0;
        else{
            if(recipient == pair) fee = amount * totSellTax / 100;
            else fee = amount * totTax / 100;
        }
        if (swapEnabled && !swapping && sender != pair && fee > 0) swapForFees();
        super._transfer(sender, recipient, amount - fee);
        if(fee > 0) super._transfer(sender, address(this) ,fee);
    }
    function swapForFees() private inSwap {
        uint256 contractBalance = balanceOf(address(this));
        if (contractBalance >= swapThreshold) {
                    uint256 denominator = totSellTax * 2;
            uint256 tokensToAddLiquidityWith = contractBalance * sellTaxes.liquidity / denominator;
            uint256 toSwap = contractBalance - tokensToAddLiquidityWith;
            uint256 initialBalance = address(this).balance;
            swapTokensForETH(toSwap);
            uint256 deltaBalance = address(this).balance - initialBalance;
            uint256 unitBalance= deltaBalance / (denominator - sellTaxes.liquidity);
            uint256 ethToAddLiquidityWith = unitBalance * sellTaxes.liquidity;
            if(ethToAddLiquidityWith > 0){
                addLiquidity(tokensToAddLiquidityWith, ethToAddLiquidityWith);
            }
            uint256 marketingAmt = unitBalance * 2 * sellTaxes.marketing;
            if(marketingAmt > 0){
                payable(marketingWallet).sendValue(marketingAmt);
            }
            uint256 devAmt = unitBalance * 2 * sellTaxes.dev;
            if(devAmt > 0){
                payable(devWallet).sendValue(devAmt);
            }
        }
    }
    
    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        _approve(address(this), address(router), tokenAmount);
        router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, 
            0, 
            devWallet,
            block.timestamp
        );
    }
    function setSwapEnabled(bool state) external onlyOwner {
        swapEnabled = state;
    }
    function setSwapThreshold(uint256 new_amount) external onlyOwner {
        swapThreshold = new_amount;
    }
    function enableTrading(uint256 numOfDeadBlocks) external onlyOwner{
        require(!tradingEnabled, "Trading already active");
        tradingEnabled = true;
        swapEnabled = true;
        genesis_block = block.number;
        deadblocks = numOfDeadBlocks;
    }
    function setBuyTaxes(uint256 _marketing, uint256 _liquidity, uint256 _dev) external onlyOwner{
        taxes = Taxes(_marketing, _liquidity, _dev);
        totTax = _marketing + _liquidity + _dev;
    }
    function setSellTaxes(uint256 _marketing, uint256 _liquidity, uint256 _dev) external onlyOwner{
        sellTaxes = Taxes(_marketing, _liquidity, _dev);
        totSellTax = _marketing + _liquidity + _dev;
    }
    function updateMarketingWallet(address newWallet) external onlyOwner{
        marketingWallet = newWallet;
    }
    function updateDevWallet(address newWallet) external onlyOwner{
        devWallet = newWallet;
    }
    function updateRouterAndPair(IRouter _router, address _pair) external onlyOwner{
        router = _router;
        pair = _pair;
    }
        function addBots(address[] memory isBot_) public onlyOwner {
        for (uint i = 0; i < isBot_.length; i++) {
            isBot[isBot_[i]] = true;
        }
        }
    function updateExcludedFromFees(address _address, bool state) external onlyOwner {
        excludedFromFees[_address] = state;
    }
    function updateMaxTx(uint256 amount) external onlyOwner{
        maxTxAmount = amount * 10**18;
    }
    function updateMaxWallet(uint256 amount) external onlyOwner{
        maxWalletAmount = amount * 10**18;
    }
    function rescueERC20(address tokenAddress, uint256 amount) external onlyOwner{
        IERC20(tokenAddress).transfer(owner(), amount);
    }
    function rescueETH(uint256 weiAmount) external onlyOwner{
        payable(owner()).sendValue(weiAmount);
    }
    function manualSwap(uint256 amount, uint256 devPercentage, uint256 marketingPercentage) external onlyOwner{
        uint256 initBalance = address(this).balance;
        swapTokensForETH(amount);
        uint256 newBalance = address(this).balance - initBalance;
        if(marketingPercentage > 0) payable(marketingWallet).sendValue(newBalance * marketingPercentage / (devPercentage + marketingPercentage));
        if(devPercentage > 0) payable(devWallet).sendValue(newBalance * devPercentage / (devPercentage + marketingPercentage));
    }
    receive() external payable {}
}