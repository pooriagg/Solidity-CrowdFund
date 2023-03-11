==================================
Crowd Fund Smart Contract Document
==================================

.. code-block:: solidity

  interface ICrowdFund {
     struct Campaign {
        address creator;
        uint goal;
        uint pledged;
        uint startedAt;
        uint endedAt;
        bool claimed;
        bool canceled;
    }
    
    function launch(
        uint _goal,
        uint _startedAt,
        uint _endedAt
    ) external;

    function pledge(uint _id, uint _amount) external;

    function unpledge(uint _id, uint _amount) external;

    function claim(uint _id);
    
    function cancel(uint _id) external;

    function refund(uint _id) external;

    function userInfo(address _addr, uint _id) external view returns(uint);

    function campaignInfo(uint _id) external view returns(Campaign memory);
  }
  
------------------------------------------------------------------------------------------------

launch a campaign
=====================

.. code-block:: solidity
  
    function launch(
        uint _goal,
        uint _startedAt,
        uint _endedAt
    ) external;
    
Will launch a new campaign.

----------
Parameters
----------

1. ``_goal`` - ``uint256``: The amount of the token (currency) in decimal format.
2. ``_startAt`` - ``uint256``: The time which the crowdFund will start.
3. ``_endedAt`` - ``uint256``: The time which the crowdFund will end and stop.

------------------------------------------------------------------------------------------------

pledge to a campaign
=====================

.. code-block:: solidity

  function pledge(uint _id, uint _amount) external;
  
User can call this function to pledge to a campaign with specific ``_amount`` of the token.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the campaign.
2. ``_amount`` - ``uint256``: The ``_amount`` of the token which user wishes to pledge to the campaign.

------------------------------------------------------------------------------------------------

unpledge to a campaign
=======================

.. code-block:: solidity

  function unpledge(uint _id, uint _amount) external;
  
User can unplege their pledged amount to a valid campaign.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the campaign.
2. ``_amount`` - ``uint256``: The amount of the token which user wishes to unpledge.

------------------------------------------------------------------------------------------------

claim the pledged funds
========================

.. code-block:: solidity
  
  function claim(uint _id);
  
campaign creator can claim all pledged funds to his/her/their campaign after ending the campaign.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the campaign.

------------------------------------------------------------------------------------------------

cancel the campaign
======================

.. code-block:: solidity

  function cancel(uint _id) external;
  
campaign creator can cancel his/her/their created campaign before it ends.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the campaign.

------------------------------------------------------------------------------------------------

refund fund
=============

... code-block:: solidity
  
  function refund(uint _id) external;
  
User can refund their funds from canceled campaigns.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the canceled campaign.

------------------------------------------------------------------------------------------------

get user info
================

.. code-block:: solidity

  function userInfo(address _addr, uint _id) external view returns(uint);
  
Will return the pledged amount of the address ``_addr`` to the campaign id ``_id``.

----------
Parameters
----------

1. ``_addr`` - ``adddress``: The address of the target user.
2. ``_id`` - ``uint256``: The id of the campaign.

----------
Returns
----------

1. ``uint256``: The pledged amount in decimal.

------------------------------------------------------------------------------------------------

get camapign full info
================

.. code-block:: solidity

  function campaignInfo(uint _id) external view returns(Campaign memory);
  
Will return the full information of the campaign id ``_id``.

----------
Parameters
----------

1. ``_id`` - ``uint256``: The id of the campaign.

----------
Returns
----------

1. ``Campaign`` - ``Campaign's struct``: The struct of the campaign.
