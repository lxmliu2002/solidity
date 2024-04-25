// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { B } from "./B.sol";

contract A {
    uint public aData;
    B public bContract;

    constructor(uint _aData, uint _bData, uint _cData) {
        aData = _aData;
        bContract = new B(_bData, _cData);
    }
}
