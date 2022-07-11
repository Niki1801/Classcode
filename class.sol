// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.4.20;

/**
* @title SafeMath
* @dev Math operations with safety checks that throws an error
*/

library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256){
      if(a == 0){
          return 0;
      }
      uint256 c = a * b;
      assert (c / a == b);
      return c;
  }
  function div(uint256 a, uint256 b) internal pure returns (uint256){
      //assert (b > 0); //Solidity automatically throws when deviding by 0
      uint256 c = a / b;
      //assert (a == b * c + a % b ); //There is no case in which this dosn't holds
      return c;
  }
  function sub(uint256 a, uint256 b) internal pure returns (uint256){
      assert(b <= a);
      return a - b;
  }
  function add(uint256 a, uint256 b) internal pure returns (uint256){
      uint256 c = a + b;
      assert(c >= a);
      return c;
  }
}


contract CLASS {
    using SafeMath for uint256;
    //Name of the token
    string public constant name = "Class";

    //Symbol of token
    string public constant symbol = "CLS";
    uint8 public constant decimal = 18;
    uint public  _totalsupply = 2500000000 *10 **18; // 2.5 Billion CLS Coins
    address public owner;
    uint256 constant public _price_token = 20000;
    uint256 no_of_tokens;
    uint256 bonus_token;
    uint256 total_token;
    bool stopped = false;
    uint256 public pre_startdate;
    uint256 public ico_startdate;
    uint256 pre_enddate;
    uint256 ico_enddate;
    uint256 maxCap_PRE;
    uint256 maxCap_ICO;
    bool public icoRunningStatus = true;
    mapping(address => uint) balance;
    mapping(address => mapping(address => uint))allowed;
    address ethFundMain = 0xEA5602913966011edf21dC7727d1f7447B46503a; //needs to change
    uint256 public Numtokens;
    uint256 public bonustoken;
    uint256 public ethreceived;
    uint bonusCalculationFactor;
    uint public bonus;
    uint x;

    enum Stages {
        NOTSTARTED,
        PREICO,
        ICO,
        ENDED
    }

    Stages public stage;

    modifier atStage(Stages _stage){
        if (stage != _stage)
        //Contract not in expected state
        revert();
        _;
    }

    modifier onlyOwner(){
        if (msg.sender != owner) {
            revert();
        }
        _;
    }
    function ClassCoin() public
    {
        owner = msg.sender;
        balance[owner] = 1250000000 *10 **18; //1.25 billion given to owner
        stage = Stages.NOTSTARTED;
        //Transfer(0, owner, balance[owner]);
    }

    function () public payable {
        require(stage != Stages.ENDED);
        require(!stopped && msg.sender != owner);
        if(stage == Stages.PREICO && now <= pre_enddate)
        {
            no_of_tokens = (msg.value).mul(_price_token);
            ethreceived = ethreceived.add(msg.value);
            bonus = bonuscalpre();
            bonus_token = ((no_of_tokens).mul(bonus)).div(100);
            total_token = no_of_tokens + bonus_token;
            Numtokens = Numtokens.add(no_of_tokens);
            bonustoken = bonustoken.add(bonus_token);
            transferTokens(msg.sender, total_token);
        }
        else if(stage == Stages.ICO && now <= ico_enddate){
            no_of_tokens = ((msg.value).mul(_price_token));
            ethreceived = ethreceived.add(msg.value);
            bonus = bonuscalico(msg.value);
            bonus_token = ((no_of_tokens).mul(bonus).div(100)); //bonus calculation
            total_token =  no_of_tokens + bonus_token;
            Numtokens = Numtokens.add(no_of_tokens);
            bonustoken = bonustoken.add(bonus_token);
            transferTokens(msg.sender, total_token);
        }
         else{
            revert();
        }
    }
        //bonus calculation for preico on per day basis
        function bonuscalpre() private returns (uint256) {
            uint bon = 30;
            bonusCalculationFactor = (block.timestamp.sub(pre_startdate)).div(86400); //
            if(bonusCalculationFactor == 0){
                bon = 30;
            }
            else if (bonusCalculationFactor >= 15){
                bon = 2;
            }else {
                bon -= bonusCalculationFactor * 2;
            }
            return bon;
        }

        //bonus calculation for ico on purchase basis
    function bonuscalico(uint256 y)private returns(uint256){
        x = y.div(10 ** 18);
        uint256 bon;

        if(x >= 2 && x < 5){
            bon = 1;
        }else if(x >= 5 && x < 15){
            bon =2;
        }else if(x >= 15 && x < 25){
            bon =3;
        }else if(x >= 25 && x < 40){
            bon =4;
        }else if(x >= 40 && x < 60){
            bon =5;
        }else if(x >= 60 && x < 70){
            bon =6;
        }else if(x >= 70 && x < 80){
            bon =7;
        }else if(x >= 80 && x < 90){
            bon =8;
        }else if(x >= 90 && x < 100){
            bon =9;
        }else if( x>=100){
            bon = 10;
        }else{
            bon = 0;
        }
        return bon;
    }

    function start_PREICO() public atStage(Stages.NOTSTARTED) onlyOwner{
        stage = Stages.PREICO;
        stopped = false;
        maxCap_PRE = 350000000 * 10 ** 18;  //350 million
        balance[address(this)] = maxCap_PRE;
        pre_startdate = now;
        pre_enddate = now + 20 days; // time for preICO
        //Transfer(0, address(this), balance[address(this)]);
    }

     function start_ICO() public onlyOwner atStage(Stages.PREICO){
        stage = Stages.ICO;
        stopped = false;
        maxCap_ICO = 900000000 * 10 ** 18;  //900 million
        balance[address(this)] = maxCap_ICO;
        ico_startdate = now;
        ico_enddate = now + 25 days; // time for ICO
       // Transfer(0, address(this), balance[address(this)]);
    }

    // called by the owner, pause ICO
    function StopICO() external onlyOwner {
        stopped = true;
    }

    function releaseICO() external onlyOwner {
        stopped = false;
    }

    function end_ICO() external onlyOwner atStage(Stages.ICO){
        require(now > ico_enddate);
        stage = Stages.ENDED;
        icoRunningStatus = false;
        _totalsupply = (_totalsupply).sub(balance[address(this)]);
        balance[address(this)]=0;
       // Transfer(address(this),0 ,balance[address(this)]);
    }
    //This function can be used by owner in emergency to update the running status parameter
    function fixSpecications(bool RunningStatus) external onlyOwner{
        icoRunningStatus = RunningStatus;
    }
    // What is the total supply of each token
    function totalSupply() public view returns (uint256 total_Supply){
        total_Supply = _totalsupply;
    }

    //What is the balance of a particular account
    function tokenBalanceOf(address _owner)public view returns (uint256){
        return balance[_owner];
    }

    function transferFrom( address _from, address _to, uint256 _amount) public returns(bool success){
        require( _to != 0x0);
        require(balance[_from] >= _amount && allowed[_from][msg.sender]>= _amount && _amount > 0);
        balance[_from] = (balance[_from]).sub(_amount);
        allowed[_from][msg.sender] = (allowed[_from][msg.sender]).sub(_amount);
        balance[_to] = (balance[_to]).add(_amount);
        //Transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount)public returns (bool success) {
        require(!icoRunningStatus);
        require(_spender != 0x0);
        allowed[msg.sender][_spender] = _amount;
        //Approval(msg.sender, _spender, _amount);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint remaining){
        require( _owner != 0x0 && _spender !=0x0);
        return allowed[_owner][_spender];
    }

    //Transfer the balance from owners account to another account
    function transfer(address _to, uint256 _amount) public returns (bool success){
        if(icoRunningStatus && msg.sender == owner){
            require(balance[owner] >= _amount && _amount >= 0 && balance[_to] + _amount > balance[_to]);
            balance[owner] = (balance[owner]).sub(_amount);
            balance[_to] = (balance[_to]).add(_amount);
            //Transfer(owner, _to, _amount);
            return true;
        }
        else if(!icoRunningStatus){
            require(balance[msg.sender] >= _amount && _amount >= 0 && balance[_to] + _amount > balance[_to]);
            balance[msg.sender] = (balance[msg.sender]).sub(_amount);
            balance[_to] = (balance[_to]).add(_amount);
           // Transfer(msg.sender, _to, _amount);
            return true;
        }
        else
        revert();
    }

    //Transfer the balance from owner's account to another account
    function transferTokens(address _to, uint256 _amount) private returns (bool success){
        require( _to != 0x0);
        require(balance[address(this)] >= _amount && _amount > 0);
        balance[address(this)] = (balance[address(this)]).sub(_amount);
        balance[_to] = (balance[_to]).add(_amount);
        //Transfer(address(this), _to, _amount);
        return true;
    }

     function transferby(address _to, uint256 _amount) external onlyOwner returns (bool success){
        require( _to != 0x0);
        require(balance[address(this)] >= _amount && _amount > 0);
        balance[address(this)] = (balance[address(this)]).sub(_amount);
        balance[_to] = (balance[_to]).add(_amount);
       // Transfer(address(this), _to, _amount);
        return true;
    }

    //Incase the ownership needs to be transfered
    function transferOwnership(address newOwner) public onlyOwner{
        balance[newOwner] = (balance[newOwner]).add(balance[owner]);
        balance[owner] = 0;
        owner = newOwner;
    }

    function drain()external onlyOwner {
        ethFundMain.transfer(this.balance);
    }
    
}