// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import "@chainlink/contracts/src/v0.8/interfaces/AutomationCompatibleInterface.sol";

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);

} 

 /* Errors */
 error UpkeepNotNeeded(uint256 currentBalance);


contract LINKvsUSDC is AutomationCompatibleInterface{

    // Chainlink Automatic Variables
    uint256 private immutable i_interval;
    uint256 private s_lastTimeStamp;

    constructor (uint256 interval){
        i_interval = interval;
        s_lastTimeStamp = block.timestamp;
    }

    address public constant routerAddress = 0xE592427A0AEce92De3Edee1F18E0157C05861564;	

    ISwapRouter public immutable swapRouter = ISwapRouter(routerAddress);

    // This example swaps DAI/WETH9 for single path swaps and DAI/USDC/WETH9 for multi path swaps.

    address public constant LINK = 0x326C977E6efc84E512bB9C30f76E30c160eD06FB;
    address public constant USDC = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;

    IERC20 public linkToken = IERC20(LINK);

    // For this example, we will set the pool fee to 0.3%.
    uint24 public constant poolFee = 3000;

    /// @notice swapExactInputSingle swaps a fixed amount of DAI for a maximum possible amount of WETH9
    /// using the DAI/WETH9 0.3% pool by calling `exactInputSingle` in the swap router.
    /// @dev The calling address must approve this contract to spend at least `amountIn` worth of its DAI for this function to succeed.
    /// @param amountIn The exact amount of DAI that will be swapped for WETH9.
    /// @return amountOut The amount of WETH9 received.
    function swapExactInputSingle(uint256 amountIn) external returns (uint256 amountOut) {
        // msg.sender must approve this contract

        // Transfer the specified amount of DAI to this contract.

        // Approve the router to spend DAI.
        linkToken.approve(address(swapRouter), amountIn);

        // Naively set amountOutMinimum to 0. In production, use an oracle or other data source to choose a safer value for amountOutMinimum.
        // We also set the sqrtPriceLimitx96 to be 0 to ensure we swap our exact input amount.
        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: USDC,
                tokenOut: LDO,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = swapRouter.exactInputSingle(params);
    }

    /// @notice swapExactOutputSingle swaps a minimum possible amount of DAI for a fixed amount of WETH.
    /// @dev The calling address must approve this contract to spend its DAI for this function to succeed. As the amount of input DAI is variable,
    /// the calling address will need to approve for a slightly higher amount, anticipating some variance.
    /// @param amountOut The exact amount of WETH9 to receive from the swap.
    /// @param amountInMaximum The amount of DAI we are willing to spend to receive the specified amount of WETH9.
    /// @return amountIn The amount of DAI actually spent in the swap.
    function swapExactOutputSingle(uint256 amountOut, uint256 amountInMaximum) external returns (uint256 amountIn) {
        // Transfer the specified amount of DAI to this contract.

        // Approve the router to spend the specifed `amountInMaximum` of DAI.
        // In production, you should choose the maximum amount to spend based on oracles or other data sources to acheive a better swap.
        linkToken.approve(address(swapRouter), amountInMaximum);

        ISwapRouter.ExactOutputSingleParams memory params =
            ISwapRouter.ExactOutputSingleParams({
                tokenIn: USDC,
                tokenOut: LDO,
                fee: poolFee,
                recipient: address(this),
                deadline: block.timestamp,
                amountOut: amountOut,
                amountInMaximum: amountInMaximum,
                sqrtPriceLimitX96: 0
            });

        // Executes the swap returning the amountIn needed to spend to receive the desired amountOut.
        amountIn = swapRouter.exactOutputSingle(params);

        // For exact output swaps, the amountInMaximum may not have all been spent.
        // If the actual amount spent (amountIn) is less than the specified maximum amount, we must refund the msg.sender and approve the swapRouter to spend 0.
        if (amountIn < amountInMaximum) {
            linkToken.approve(address(swapRouter), 0);
            linkToken.transfer(address(this), amountInMaximum - amountIn);
        }
    }

    function checkUpkeep(
        bytes memory /* checkData */
    ) public view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        bool timePassed = ((block.timestamp - s_lastTimeStamp) > i_interval);
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded = (timePassed && hasBalance);
        return (upkeepNeeded, "0x0"); // can we comment this out?
    }
    
        function performUpkeep(bytes calldata /* performData */) external override {
        (bool upkeepNeeded, ) = checkUpkeep("");
        // require(upkeepNeeded, "Upkeep not needed");
        if (!upkeepNeeded) {
            revert UpkeepNotNeeded(
                address(this).balance,
            );
        }
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            uint256 linkBalance = linkToken.balanceOf(address(this));
            uint256 amountOut = swapExactInputSingle(linkBalance);
        }
    }
}