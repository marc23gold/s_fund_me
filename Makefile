-include .env

build:; forge build

deploy-sepolia:
	forge script script/FundMeDeploy.s.sol:FundMeDeploy --rpc-url $(S_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN) -vvvv