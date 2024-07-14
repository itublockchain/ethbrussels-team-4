// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract CampaignArray {
    address[] public all_campaigns;

    event CampaignCreated(address campaignAddress, address owner, uint256 campaignId, uint256 perDonate, uint256 unlockTime);

    function createCampaign(uint256 _perDonate, uint256 _unlockTime) external {
        require(1 days * _unlockTime + block.timestamp> block.timestamp, "Unlock time should be in the future");
        address newCampaign = address(new DonatePool(msg.sender, _perDonate, _unlockTime));
        all_campaigns.push(newCampaign);
        emit CampaignCreated(newCampaign, msg.sender, all_campaigns.length - 1, _perDonate, _unlockTime);
    }

    function getAllCampaigns() external view returns (address[] memory) {
        return all_campaigns;
    }
}

contract DonatePool {
    struct Campaign {
        address owner; //lazım olmayabilir sonra dön
        uint256 total_donations;
        uint256 per_donate;
        uint unlockTime;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignId;
    mapping(string => address) public token_addresses;
    uint256 public constant gas_fee = 5.5 * 10**9; 

    event DonationReceived(uint256 campaignId, address donater, uint256 amount, address token);
    event DonationGived(uint256 campaignId, address owner, uint256 total_donations);

    constructor(address _owner, uint256 _perDonate, uint _unlockTime) {
        require(block.timestamp < 1 days * _unlockTime + block.timestamp, "Unlock time should be in the future");
        token_addresses["USDT"] = 0xf55BEC9cafDbE8730f096Aa55dad6D22d44099Df;
        token_addresses["USDC"] = 0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4;
        campaigns[campaignId].owner = _owner;
        campaigns[campaignId].total_donations = 0;
        campaigns[campaignId].per_donate = _perDonate;
        campaigns[campaignId].unlockTime = _unlockTime;
        campaignId++;
    }
    
    modifier isCampaign_open(uint256 _campaignId) {
        require(_campaignId < campaignId, "Campaign does not exist");
        require(block.timestamp < campaigns[_campaignId].unlockTime * 1 days + block.timestamp, "Time of the campaign is over");
        _;
    }
    
    function donate(uint256 _campaignId, uint256 _amount, string calldata _tokenSymbol, address _user) public payable isCampaign_open(_campaignId){
        require(_campaignId < campaignId, "Campaign does not exist");
        require(_amount > 0, "Amount must be greater than 0");
        address tokenAddress = token_addresses[_tokenSymbol];
        require(tokenAddress != address(0), "Invalid token address");
        IERC20 token = IERC20(tokenAddress);
        require(token.balanceOf(msg.sender) >= _amount, "Insufficient balance");
        require(token.approve(_user, _amount));
        require(token.transferFrom(msg.sender, address(this), _amount), "Token transfer failed");
        campaigns[_campaignId].total_donations += _amount;
        emit DonationReceived(_campaignId, msg.sender, _amount, tokenAddress);
    }

    function donate_withdraw(uint256 _campaignId, string calldata _tokenSymbol) public { // User who needs takes donation
        require(block.timestamp > campaigns[_campaignId].unlockTime * 1 days + block.timestamp, "Time of the campaign is not over");
        require((campaigns[_campaignId].total_donations)/(campaigns[_campaignId].per_donate) > 1, "Pool is not enough");
        address tokenAddress = token_addresses[_tokenSymbol];
        IERC20 token = IERC20(tokenAddress);
        require(token.transferFrom(address(this), msg.sender, campaigns[campaignId].per_donate), "Token transfer failed");   
        campaigns[_campaignId].total_donations -= campaigns[_campaignId].per_donate;
        emit DonationGived(_campaignId, msg.sender, campaigns[_campaignId].total_donations);
    }
}