var tickets = artifacts.require("./TicketToken.sol");

module.exports = function(deployer) {
  deployer.deploy(tickets);
};
