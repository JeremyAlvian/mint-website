import React, {useState} from "react";
import { Box, Button, Flex } from "@chakra-ui/react";

import { ethers } from "ethers";


const Navbar = ({ accounts, setAccounts }) => {
  const isConnected = Boolean(accounts[0]);
  const [signer, setSigner] = useState([])


  async function connectAccount() {
    if (window.ethereum) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      let accounts = await provider.send("eth_requestAccounts", []);
      setSigner(accounts);
      provider.on('accountsChanged', function (accounts) {
        setSigner(accounts);
    });
    const signer = provider.getSigner();

    const address = await signer.getAddress();
    setAccounts(address)
    }
  }

  console.log({accounts, signer});


  return (
    <Flex justify="center" algin="center" padding="30px">
      {/* Left side - Social Media Icons */}
      {/* <Flex justify="space-around" width="40$" padding="0 75px"> */}
        {/* <Link href= "https://www.facebook.com">
            <Image src={Facebook} boxSize="42px" margin="0 15px" />
        </Link>
        <Link href= "https://www.twitter.com">
            <Image src={Twitter} boxSize="42px" margin="0 15px" />
        </Link>
        <Link href= "https://www.gmail.com">
            <Image src={Email} boxSize="42px" margin="0 15px" />
        </Link> */}
      {/* </Flex> */}

      {/* Right side - Section and Connect */}
    {/* Connect */}
    {isConnected ? (
        <Box margin="0 15px">{accounts}</Box>
      ) : (
        <Button
        backgroundColor='#D6517D'
        borderRadius="5px"
        boxShadow="0px 2px 2px 1px #0F0F0F"
        color="white"
        cursor="pointer"
        fontFamily="inherit"
        padding="15px"
        margin="0 15px"
        onClick={connectAccount}>Connect</Button>
      )}
    </Flex>
  );
};

export default Navbar;
