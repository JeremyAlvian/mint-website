import { useEffect, useState } from "react";
import { ethers, BigNumber } from "ethers";
import { Box, Button, Divider, Flex, Input, Text } from "@chakra-ui/react";
import fuzzNFT from "./FuzzNFT.json";
import axios from "axios";


const FuzzNFTAddress = "0xe333EC0268F4Fbb69aFc3651c7be42cce141Bf54";


const MainMint = ({ accounts, setAccounts }) => {
  const [mintAmount, setMintAmount] = useState(1);
  const isConnected = Boolean(accounts[0]);
  const [status, setStatus] = useState("");
  const [supply, setSupply] = useState([]);
  const [maxQty, setMaxQty] = useState([]);
  const [price, setPrice] = useState([]);



  useEffect(() => {
    const fetchStatus = async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(FuzzNFTAddress, fuzzNFT.abi, signer);
      const statusContract = await contract.status();
      setStatus(statusContract);
    };
  
    fetchStatus().catch(console.error);
  })

  useEffect(() => {
    const fetchSupply = async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(FuzzNFTAddress, fuzzNFT.abi, signer);
      try {
        let totalSupp;
        const supplyContract = await contract.totalSupply();
        totalSupp = 
            ((parseInt(Number(supplyContract))))
       
        console.log("total supply: ", totalSupp)
        setSupply(totalSupp);

      } catch (error) {
        console.log("error: ", error);
        alert(error.message);
      }
    };
    
    fetchSupply().catch(console.error);
  })

  useEffect(() => {
    const fetchMaxQty = async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(FuzzNFTAddress, fuzzNFT.abi, signer);
      try {
        let maxQty;
        const maxQtyContract = await contract.SALES_MAX_QTY();
        maxQty = 
            ((parseInt(Number(maxQtyContract))))
       
        console.log("max QTY: ", maxQty)
        setMaxQty(maxQty);

      } catch (error) {
        console.log("error: ", error);
        alert(error.message);
      }
    };
    
    fetchMaxQty().catch(console.error);
  })

  useEffect(() => {
    const fetchPrice = async () => {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(FuzzNFTAddress, fuzzNFT.abi, signer);
      try {
        let price;
        const priceContract = await contract.getPrice();
        price = 
            ((parseInt(Number(priceContract)) / 10 ** 18))
       
        console.log("price: ", price)
        setPrice(price);

      } catch (error) {
        console.log("error: ", error);
        alert(error.message);
      }
    };
    
    fetchPrice().catch(console.error);
  })
//   useEffect(() => {
//   const fetchSupply = async() => {
//     const provider = new ethers.providers.Web3Provider(window.ethereum);
//     const signer = provider.getSigner();
//     const contract = new ethers.Contract(FuzzNFTAddress, fuzzNFT.abi, signer);
//     const total = await contract.totalSupply();
//     setSupply(total);
//   }
//   fetchSupply().catch(console.error);

// })

  async function handleMint() {
    if (window.ethereum && isConnected) {
      const provider = new ethers.providers.Web3Provider(window.ethereum);
      const signer = provider.getSigner();
      const contract = new ethers.Contract(
        FuzzNFTAddress,
        fuzzNFT.abi,
        signer
      );
      try {
       let response;
       const statusContract = await contract.status();
       setStatus(statusContract);
       const price = await contract.getPrice();
       if(status === "PublicSale"){
        response = await contract.publicMint(BigNumber.from(mintAmount), {
          value: ethers.utils.parseEther(
            ((parseInt(Number(price)) / 10 ** 18) * mintAmount).toString()
          ),
        });
       }
       if (status === "PreSale") {
        const presale = await axios.get(
          `${process.env.REACT_APP_WHITELIST_URL}${accounts}`
        );
        console.log(presale);
        setTimeout(async () => {
          response = await contract.presaleMint(
            presale.data.proof,
            BigNumber.from(mintAmount),
            BigNumber.from(presale?.data?.allowance),
            {
              value: ethers.utils.parseEther(
                ((parseInt(Number(price)) / 10 ** 18) * mintAmount).toString()
              ),
            }
          );
        }, 3000);
      }
       if (status === "ReservedSale") {
        const reserved = await axios.get(
          `${process.env.REACT_APP_RESERVED_URL}${accounts}`
        );
        setTimeout(async () => {
          response = await contract.reservedMint(reserved?.data?.proof);
        }, 3000);
      }
      console.log("response: ", response)
      } catch (err) {
        console.log("error: ", err);
        alert(err.message);
      }
    }
  }

  const handleDecrement = () => {
    if (mintAmount <= 1 || status === "ReservedSale") return;
    setMintAmount(mintAmount - 1);
  };

  const handleIncrement = () => {
    if (mintAmount >= 3 || status === "ReservedSale") return;
    setMintAmount(mintAmount + 1);
  };

  return (
    <Flex justify="center" align="center" height="100vh" paddingBottom="150px">
      <Box width="520px">
        <div>
          <Text fontSize="48px" textShadow="0 5px #000000">
            Fuzz NFT
          </Text>
          <Text
            fontSize="30px"
            letterSpacing="-5.5%"
            fontFamily="VT323"
            textShadow="0 2px 2px #000000"
          >
            It's 2078. Can the Fuzz NFT save humans from destructive
            rampant NFT speculation? Mint Fuzz to find out. <Divider />

            Total Supply : {supply} / {maxQty}
          </Text>
         
          
        </div>

        {isConnected ? (
          <div>
             <Text  fontSize="30px"
            letterSpacing="-5.5%"
            fontFamily="VT323"
            textShadow="0 2px 2px #000000">
             Now is "{status}" <br />
                Price : {price * mintAmount} eth
             </Text>
                
            <Flex align="center" justify="center">
              <Button
                backgroundColor="#D6517D"
                borderRadius="5px"
                boxShadow="0px 2px 2px 1px #0F0F0F"
                color="white"
                cursor="pointer"
                fontFamily="inherit"
                padding="15px"
                marginTop="10px"
                onClick={handleDecrement}
              >
                {" "}
                -{" "}
              </Button>
              <Input
                readOnly
                fontFamily="inherit"
                width="100px"
                height="40px"
                textAlign="center"
                paddingLeft="19px"
                marginTop="10px"
                type="number"
                value={mintAmount}
              />
              <Button
                backgroundColor="#D6517D"
                borderRadius="5px"
                boxShadow="0px 2px 2px 1px #0F0F0F"
                color="white"
                cursor="pointer"
                fontFamily="inherit"
                padding="15px"
                marginTop="10px"
                onClick={handleIncrement}
              >
                {" "}
                +{" "}
              </Button>
            </Flex>
            <Button
              backgroundColor="#D6517D"
              borderRadius="5px"
              boxShadow="0px 2px 2px 1px #0F0F0F"
              color="white"
              cursor="pointer"
              fontFamily="inherit"
              padding="15px"
              marginTop="10px"
              onClick={handleMint}
            >
              Mint Now
            </Button>
          </div>
        ) : (
          <Text
          marginTop="70px"
          fontSize="30px"
          letterSpacing="-5.5%"
          fontFamily="VT323"
          textShadow="0 3px #000000"
          color="#D6517D"
          >You must be connected to Mint. </Text>
        )}
      </Box>
    </Flex>
  );
};

export default MainMint;
