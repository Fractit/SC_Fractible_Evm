const { ethers } = require("ethers");
require("dotenv").config();

async function main() {
  // Connect to the network
  const provider = new ethers.JsonRpcProvider(process.env.RPC_URL);

  // Setup deployer wallet
  const privateKey = process.env.PRIVATE_KEY;
  const wallet = new ethers.Wallet(privateKey, provider);

  // Contract deployment parameters
  const pUsdAddress = "0xe644F07B1316f28a7F134998e021eA9f7135F351";
  const name = "FVH";
  const symbol = "FVH";
  const initialSupply = ethers.parseUnits("645105", 6); // 645105e6

  // Get the contract factory
  const fractibleJson = require("./out/Fractible.sol/Fractible.json");
  const Fractible = await ethers.ContractFactory.fromSolidity(
    fractibleJson,
    wallet
  );

  console.log("Deploying Fractible contract...");

  console.log("Deploying Fractible contract...");

  // Deploy the contract
  const fractible = await Fractible.deploy(
    wallet.address, // deployer
    pUsdAddress, // pUsd token address
    name,
    symbol,
    initialSupply
  );

  await fractible.waitForDeployment();
  const fractibleAddress = await fractible.getAddress();

  console.log("Fractible deployed to:", fractibleAddress);

  // Approve and deposit (similar to your Forge script)
  const pUsdContract = new ethers.Contract(
    pUsdAddress,
    ["function approve(address spender, uint256 amount) public returns (bool)"],
    wallet
  );

  console.log("Approving pUSD...");
  const approvalAmount = ethers.parseUnits("10000", 18); // 10000e18
  await pUsdContract.approve(fractibleAddress, approvalAmount);

  console.log("Depositing to Fractible...");
  const depositAmount = ethers.parseUnits("100", 6); // 100e6
  await fractible.deposit(depositAmount);

  console.log("Deployment and initial setup complete!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
