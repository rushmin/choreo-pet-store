import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;
import ballerina/uuid;
import ballerina/log;


type Database record {|
    string host;
    string name;
    int port;
    string username;
    string password;
|};

type Follow record {|
    string id;
    string user_id;
    string product_id;
    boolean follow;
|};


// type Product record {|
//  string name;
//  string description;
//  decimal price;
//  string variation_option;
//  string image;
 
// |};


// type Category record {|
//  string name;
//  int id;
//  string variation;
 
// |};


configurable Database database = ?;

final mysql:Client dbClient = check new (database.host, database.username, database.password, database.name, database.port);


function getProductItems(string? sku) returns ProductItems[] | error {


    log:printInfo(<string>sku);
    ProductItem[] product = [];
  

    stream<ProductItem, error?>  resultStream = dbClient->query(`select  * from product where sku = "${sku}"`);

    check from ProductItem employee in resultStream
        do {
            product.push(employee);
        };
  
    check resultStream.close();

    log:printInfo("Output : " + product.toJsonString());

    ProductItems[] productItems = [];
    if product is ProductItem[] {
        productItems = product.map(br => new ProductItems(br));
    }

    return productItems;
}


function getAllProductItems() returns ProductItems []|error {

    log:printInfo("function is called ###########");

    ProductItem[] product = [];

    stream<ProductItem, error?>  resultStream = dbClient->query(`select  * from product`);

    check from ProductItem employee in resultStream
        do {
            product.push(employee);
        };
  
    check resultStream.close();
    log:printInfo(product.toJsonString());

    ProductItems[] productItems = [];
    if product is ProductItem[] {
        productItems = product.map(br => new ProductItems(br));
    }
    return productItems;
}


function addProductItem(string? name, string? description, string? image,
    decimal? price, string? variation) returns int|error {

    string uuid1String = uuid:createType1AsString();

    sql:ExecutionResult finalResult = check dbClient->execute(
        `INSERT INTO product(name, description, image, sku, price, variation) VALUES 
        (${name},${description},${image},${uuid1String}, ${price}$, ${variation})`);
    return <int>finalResult.lastInsertId;

}

function 

getFollows(string? userId) returns Follow []|error {

    log:printInfo("function is called ###########");

    Follow[] follows = [];

    stream<Follow, error?>  resultStream = dbClient->query(`select  * from product_review where user_id=${userId}`);

    check from Follow employee in resultStream
        do {
            follows.push(employee);
        };
  
    check resultStream.close();
    log:printInfo(follows.toJsonString());

    return follows;
}

function addFollow(string? userId, string? sku) returns int|error {

    log:printInfo("function is called ###########");

    sql:ExecutionResult finalResult = check dbClient->execute(
        `INSERT INTO product_review(user_id, product_id, follow) VALUES 
        (${userId}, (SELECT id from product WHERE sku = ${sku}) , true)`);

    return <int>finalResult.lastInsertId;
}