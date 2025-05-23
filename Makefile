-include .env

build:; forge build

deploy-sepolia:
	forge script script/DeployFundmMe --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherescan-api-key $(ETHERSCAN_API_KEY) -vvvv