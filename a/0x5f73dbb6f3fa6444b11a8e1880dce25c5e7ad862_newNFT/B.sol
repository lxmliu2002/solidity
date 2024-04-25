// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { C } from "./C.sol";

contract B {
    uint public bData;
    C public cContract;

    constructor(uint _bData, uint _cData) {
        bData = _bData;
        cContract = new C(_cData);
    }
}
