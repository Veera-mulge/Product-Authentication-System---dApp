// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

contract Product {
    uint256 sellerCount;
    uint256 productCount;

    // Seller struct to store seller information
    struct Seller {
        uint256 sellerId; 
        bytes32 sellerName;
        bytes32 sellerBrand; 
        bytes32 sellerCode; 
        uint256 sellerNum;
        bytes32 sellerManager;
        bytes32 sellerAddress;
    }

    mapping (uint => Seller) sellers;

    // ProductItem struct to store product information
    struct ProductItem {
        uint256 productId;
        bytes32 productSN;
        bytes32 productName;
        bytes32 productBrand;
        uint256 productPrice;
        bytes32 productStatus; 
    }

    mapping (uint256 => ProductItem) productItems;
    mapping (bytes32 => uint256) productMap;
    mapping (bytes32 => bytes32) productsManufactured;
    mapping (bytes32 => bytes32) productsForSale;
    mapping (bytes32 => bytes32) productsSold;
    mapping (bytes32 => bytes32[]) productsWithSeller;
    mapping (bytes32 => bytes32[]) productsWithConsumer;
    mapping (bytes32 => bytes32[]) sellersWithManufacturer;

    // Seller Section

    // Function to add a new seller
    function addSeller(bytes32 _manufacturerId, bytes32 _sellerName, bytes32 _sellerBrand, bytes32 _sellerCode, uint256 _sellerNum, bytes32 _sellerManager, bytes32 _sellerAddress) public {
        sellers[sellerCount] = Seller(sellerCount, _sellerName, _sellerBrand, _sellerCode, _sellerNum, _sellerManager, _sellerAddress);
        sellerCount++;
        sellersWithManufacturer[_manufacturerId].push(_sellerCode);
    }

    // Function to view all sellers
    function viewSellers() public view returns(uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        // Initialize arrays to store seller information
        uint256[] memory ids = new uint256[](sellerCount);
        bytes32[] memory snames = new bytes32[](sellerCount);
        bytes32[] memory sbrands = new bytes32[](sellerCount);
        bytes32[] memory scodes = new bytes32[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        bytes32[] memory smanagers = new bytes32[](sellerCount);
        bytes32[] memory saddress = new bytes32[](sellerCount);
        
        // Populate arrays with seller information
        for(uint i = 0; i < sellerCount; i++){
            ids[i] = sellers[i].sellerId;
            snames[i] = sellers[i].sellerName;
            sbrands[i] = sellers[i].sellerBrand;
            scodes[i] = sellers[i].sellerCode;
            snums[i] = sellers[i].sellerNum;
            smanagers[i] = sellers[i].sellerManager;
            saddress[i] = sellers[i].sellerAddress;
        }
        return(ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    // Product Section
    
    // Function to add a new product
    function addProduct(bytes32 _manufacturerId, bytes32 _productName, bytes32 _productSN, bytes32 _productBrand, uint256 productPrice) public {
        productItems[productCount] = ProductItem(productCount, _productSN, _productName, _productBrand, productPrice, "Available");
        productMap[_productSN] = productCount++;
        productCount++;
        productsManufactured[_productSN] = _manufacturerId;
    }

    // Function to view all product items
    function viewProductItems() public view returns(uint256[] memory, bytes32[] memory, bytes[] memory, bytes[] memory, uint256 memory, bytes32 memory) {
        // Initialize arrays to store product information
        uint256[] memory pids = new uint256[](productCount);
        bytes32[] memory pSNs = new bytes32[](productCount);
        bytes32[] memory pnames = new bytes32[](productCount);
        bytes32[] memory pbrands = new bytes32[](productCount);
        uint256[] memory pprices = new uint256[](productCount);
        bytes32[] memory pstatus = new bytes32[](productCount);

        // Populate arrays with product information
        for (uint i = 0; i < productCount; i++){
            pids[i] = productItems[i].productId;
            pSNs[i] = productItems[i].productSN;
            pnames[i] = productItems[i].productName;
            pbrands[i] = productItems[i].productBrand;
            pprices[i] = productItems[i].productPrice;
            pstatus[i] = productItems[i].productStatus;
        } 
        return (pids, pSNs, pnames, pbrands, pprices, pstatus);
    }

    // Sell Product

    // Function for manufacturers to sell a product
    function manufacturerSellProduct(bytes32 _productSN, bytes32 _sellerCode) public {
        productsWithSeller[_sellerCode].push(_productSN);
        productsForSale[_productSN] = _sellerCode;
    }

    // Function for sellers to sell a product
    function sellerSellProduct(bytes32 _productSN, bytes32 _consumerCode) public {
        bytes32 pStatus;
        uint256 i;
        uint256 j = 0;

        if (productCount > 0) {
            for(i = 0; i < productCount; i++){
                if (productItems[i].productSN == _productSN) {
                    j = i;
                }
            }
        }

        pStatus = productItems[j].productStatus;
        if (pStatus == "Available") {
            productItems[j].productStatus = "NA";
            productsWithConsumer[_consumerCode].push(_productSN);
            productsSold[_productSN] = _consumerCode;
        }
    }

    // Function to query a list of products associated with a specific seller
    function queryProductsList(bytes32 _sellerCode) public view returns (uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory) {
        bytes32[] memory productSNs = productsWithSeller[_sellerCode];
        uint256 k = 0;

        uint256[] memory pids = new uint256[](productCount);
        bytes32[] memory pSNs = new bytes32[](productCount);
        bytes32[] memory pnames = new bytes32[](productCount);
        bytes32[] memory pbrands = new bytes32[](productCount);
        uint256[] memory pprices = new uint256[](productCount);
        bytes32[] memory pstatus = new bytes32[](productCount);

        for (uint i = 0; i < productCount; i++){
            for (uint j = 0; j < productSNs.length; i++){
                if (productItems[i].productSN == productSNs[j]) {
                    pids[k] = productItems[i].productId;
                    pSNs[k] = productItems[i].productSN;
                    pnames[k] = productItems[i].productName;
                    pbrands[k] = productItems[i].productBrand;
                    pprices[k] = productItems[i].productPrice;
                    pstatus[k] = productItems[i].productStatus;
                    k++;
                }
            }
        }
        return(pids, pSNs, pnames, pbrands, pprices, pstatus);
    }

    // Function to query a list of sellers associated with a specific manufacturer
    function querySellersList(bytes32 _manufacturerCode) public view returns (uint256[] memory, bytes32[] memory, bytes32[] memory, bytes32[] memory, uint256[] memory, bytes32[] memory, bytes32[] memory) {
        bytes32[] memory sellerCodes = sellersWithManufacturer[_manufacturerCode];
        uint256 k = 0;
        uint256[] memory ids = new uint256[](sellerCount);
        bytes32[] memory snames = new bytes32[](sellerCount);
        bytes32[] memory sbrands = new bytes32[](sellerCount);
        bytes32[] memory scodes = new bytes32[](sellerCount);
        uint256[] memory snums = new uint256[](sellerCount);
        bytes32[] memory smanagers = new bytes32[](sellerCount);
        bytes32[] memory saddress = new bytes32[](sellerCount);

        for (uint i = 0; i < sellerCount; i++){
            for (uint j = 0; sellerCodes.length; j++){
                if (sellers[i].sellerCode == sellerCodes[j]) {
                    ids[k] = sellers[i].sellerId;
                    snames[k] = sellers[i].sellerName;
                    sbrands[k] = sellers[i].sellerBrand;
                    scodes[k] = sellers[i].sellerCode;
                    snums[k] = sellers[i].sellerNum;
                    smanagers[k] = sellers[i].sellerManager;
                    saddress[k] = sellers[i].sellerAddress;
                    k++;
                    break;
                }
            }
        }
        return (ids, snames, sbrands, scodes, snums, smanagers, saddress);
    }

    // Function to get the purchase history of a consumer
    function getPurchaseHistory(bytes32 _consumerCode) public view returns(bytes32[] memory, bytes32[] memory, bytes32[] memory) {
        bytes32[] memory productSNs = productsWithConsumer[_consumerCode];
        bytes32[] memory sellerCodes = new bytes32[](productSNs.length);
        bytes32[] memory manufacturerCodes = new bytes32[](productSNs.length);

        for(uint i = 0; i < productSNs.length; i++){
            sellerCodes[i] = productsForSale[productSNs[i]];
            manufacturerCodes[i] = productsManufactured[productSNs[i]];
        }
        return (productSNs, sellerCodes, manufacturerCodes);
    }

    // Function to verify the product ownership
    function verifyProduct(bytes32 _productSN, bytes32 _consumerCode) public view returns(bool) {
        if (productsSold[_productSN] == _consumerCode) {
            return true;
        } else {
            return false;
        }
    }
}
