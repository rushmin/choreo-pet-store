import ballerinax/mysql.driver as _;
import ballerinax/mysql;
import ballerina/sql;

type Database record {|
    string host;
    string name;
    int port;
    string username;
    string password;
|};

public type ProductRecord record {|
    int? id?;
    string title;
    string description;
    string includes;
    string intended_for;
    string color;
    string material;
    decimal price;
|};

service class Product{

    private final readonly & ProductRecord prodcutRecord;

    function init(ProductRecord prodcutRecord) {
        self.prodcutRecord = prodcutRecord.cloneReadOnly();
    }
    resource function get id() returns int? {
        return self.prodcutRecord?.id;
    }
    resource function get title() returns string {
        return self.prodcutRecord.title;
    }
    resource function get description() returns string {
        return self.prodcutRecord.description;
    }
    resource function get includes() returns string {
        return self.prodcutRecord.includes;
    }
    resource function get inteded_for() returns string {
        return self.prodcutRecord.intended_for;
    }
    resource function get color() returns string {
        return self.prodcutRecord.color;
    }
    resource function get material() returns string {
        return self.prodcutRecord.material;
    }
    resource function get price() returns decimal {
        return self.prodcutRecord.price;
    }
}

configurable Database database = ?;

final mysql:Client dbClient = check new (database.host, database.username, database.password, database.name, database.port,connectionPool={maxOpenConnections: 3});

function getProducts() returns ProductRecord[]|error?{
    
    sql:ParameterizedQuery query = `SELECT * FROM product`;
    stream<ProductRecord, sql:Error?> resultStream = dbClient->query(query);

    ProductRecord[]|error? productRecords = from var {id,title, description, includes, intended_for, color, material, price} in resultStream
        select {
            id:id,
            title: title,
            description: description,
            includes: includes,
            intended_for: intended_for,
            color: color,
            material: material,
            price: price
        };

    // Product[] products = [];
    // if productRecords is ProductRecord[] {
    //     products = productRecords.map(pr => new Product(pr));
    // }

    return productRecords;
}

function addProduct(ProductRecord product) returns int|error {

    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO product(title, description, includes, intended_for, color, material, price) VALUES 
                                                          (${product.title},${product.description},${product.includes},${product.intended_for},${product.color},${product.material},${product.price})`);
    return <int>result.lastInsertId;
}

function deleteProduct(int id) returns int|error{
    sql:ExecutionResult result = check dbClient->execute(`DELETE FROM product WHERE id=${id}`);
    return <int>result.affectedRowCount;
}