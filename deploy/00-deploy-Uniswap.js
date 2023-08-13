const { network, ethers } = require("hardhat")
const { developmentChains } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    log("----------------------------------------------------")

    // LDO
    const arguments = []
    const LDO = await deploy("USDCvsLDO", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    // LINK
    const LINK = await deploy("USDCvsLINK", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    // SMATIC
    const SMATIC = await deploy("USDCvsSMATIC", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    // SNX
    const SNX = await deploy("USDCvsSNX", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    // WBTC
    const WBTC = await deploy("USDCvsWBTC", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    // WLD
    const WLD = await deploy("USDCvsWLD", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        log("Verifying...")
        await verify(LDO.address, arguments)
        await verify(LINK.address, arguments)
        await verify(SMATIC.address, arguments)
        await verify(SNX.address, arguments)
        await verify(WBTC.address, arguments)
        await verify(WLD.address, arguments)
    }
}

module.exports.tags = ["all", "sushiswap", "main"]
