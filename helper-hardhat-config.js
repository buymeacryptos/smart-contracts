const networkConfig = {
    31337: {
        name: "localhost",
    },

    11155111: {
        name: "sepolia",
        keepersUpdateInterval: "604800",
    },
    5: {
        name: "Goerli",
        keepersUpdateInterval: "60",
    },
}

const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    developmentChains,
}
