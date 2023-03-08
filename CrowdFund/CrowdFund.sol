// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.15;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
    function decimals() external view returns(uint8);
}

contract CrowdFund {

    event Launch(
        uint id,
        address indexed creator,
        uint goal,
        uint startAt,
        uint endAt
    );
    event Cancel(uint id);
    event Pledge(uint indexed id, address indexed caller, uint amount);
    event Unpledge(uint indexed id, address indexed caller, uint amount);
    event Claim(uint id);
    event Refund(uint id, address indexed caller, uint amount);

    IERC20 private immutable token;

    struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startedAt;
        uint endedAt;
        bool claimed;
        bool canceled;
    }

    uint private count = 1;

    mapping (address => mapping (uint => uint)) private pledgedAmount;
    mapping (uint => Campaign) private campaigns;

    constructor(address _token) {
        token = IERC20(_token);
    }

    function launch(
        uint _goal,
        uint _startedAt,
        uint _endedAt
    ) external {
        require(_goal > 0, "invalid goal");
        require(_startedAt >= block.timestamp, "start < now");
        require(_endedAt > _startedAt && _endedAt <= block.timestamp + 90 days, "invalid end time");

        campaigns[count] = Campaign({
            creator: msg.sender,
            goal: _goal,
            pledged: 0,
            startedAt: _startedAt,
            endedAt: _endedAt,
            claimed: false,
            canceled: false
        });

        count += 1;

        emit Launch({
            id: count - 1,
            creator: msg.sender,
            goal: _goal,
            startAt: _startedAt,
            endAt: _endedAt
        });
    }

    function cancel(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "only creator");
        require(campaign.endedAt > block.timestamp, "cannot cancel it was ended");

        campaign.canceled = true;

        emit Cancel({
            id: _id
        });
    }

    function pledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "campaign doesn't exist");
        require(campaign.canceled == false, "campaign canceled");
        require(campaign.startedAt <= block.timestamp, "campaign doesn't started");
        require(campaign.endedAt > block.timestamp, "campaign ended");

        pledgedAmount[msg.sender][_id] += _amount;
        campaign.pledged += _amount;

        try token.allowance(msg.sender, address(this)) returns(uint amount) {
            require(amount >= (_amount * (10**uint(token.decimals()))), "enough allowance needed");

            try token.transferFrom(msg.sender, address(this), _amount * (10**uint(token.decimals()))) returns(bool result) {
                require(result == true, "failed to transfer tokens");

                emit Pledge({
                    id: _id,
                    caller: msg.sender,
                    amount: _amount
                });
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("this contract is not a ERC20 token");
                } else {
                    revert("Error");
                }
            } 
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("this contract is not a ERC20 token");
            } else {
                revert("Error");
            }
        }
    }

    function unpledge(uint _id, uint _amount) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator != address(0), "campaign doesn't exist");
        require(campaign.canceled == false, "campaign canceled");
        require(pledgedAmount[msg.sender][_id] >= _amount, "insufficient pledged amount");
        require(campaign.endedAt > block.timestamp, "campaign ended");
        
        pledgedAmount[msg.sender][_id] -= _amount;
        campaign.pledged -= _amount;

        try token.transfer(msg.sender, _amount * (10**uint(token.decimals()))) returns(bool result) {
            require(result == true, "failed to transfer tokens");

                emit Unpledge({
                    id: _id,
                    caller: msg.sender,
                    amount: _amount
                });
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("this contract is not a ERC20 token");
            } else {
                revert("Error");
            }
        }
    }

    function claim(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        require(campaign.creator == msg.sender, "invalid campaign!");
        require(campaign.canceled == false, "campaign canceled");
        require(campaign.endedAt < block.timestamp, "campaign not ended yet");
        require(campaign.claimed == false, "campaign pledged token already claimed");

        campaign.claimed = true;

        try token.transfer(msg.sender, campaign.pledged * (10**uint(token.decimals()))) returns(bool result) {
            require(result == true, "failed to transfer tokens");

            emit Claim({
                id: _id
            });
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("this contract is not a ERC20 token");
            } else {
                revert("Error");
            }
        }
    }

    function refund(uint _id) external {
        Campaign storage campaign = campaigns[_id];
        uint tokens = pledgedAmount[msg.sender][_id];
        require(campaign.creator != address(0), "invalid campaign id");
        require(campaign.canceled == true, "campaign is not canceled");
        require(tokens > 0, "you didn't pledged any tokens to this campaign!");

        campaign.pledged -= tokens;
        delete pledgedAmount[msg.sender][_id];

        try token.transfer(msg.sender, tokens * (10**uint(token.decimals()))) returns(bool result) {
            require(result == true, "failed to transfer tokens");

            emit Refund({
                id: _id,
                caller: msg.sender,
                amount: tokens
            });
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("this contract is not a ERC20 token");
            } else {
                revert("Error");
            }
        }
    }

    function userInfo(address _addr, uint _id) external view returns(uint) {
        return pledgedAmount[_addr][_id];
    }

    function campaignInfo(uint _id) external view returns(Campaign memory) {
        return campaigns[_id];
    }

}