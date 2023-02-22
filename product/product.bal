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

configurable Database database = ?;

final mysql:Client dbClient = check new (database.host, database.username, database.password, database.name, database.port,connectionPool={maxOpenConnections: 3});

function getProducts() returns Product[]{
    
    sql:ParameterizedQuery query = `SELECT * FROM product`;
    stream<ProdcutRecord, sql:Error?> resultStream = dbClient->query(query);

    ProdcutRecord[]|error? productRecords = from var {id,title, description, includes, intended_for, color, material, price} in resultStream
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

    Product[] products = [];
    if productRecords is ProdcutRecord[] {
        products = productRecords.map(pr => new Product(pr));
    }

    return products;
}

function addProduct(string title, string description, string includes,
                                                string intended_for, string color,
                                                string material, decimal price) returns int|error {

    sql:ExecutionResult result = check dbClient->execute(`INSERT INTO product(title, description, includes, intended_for, color, material, price) VALUES 
                                                          (${title},${description},${includes},${intended_for},${color},${material},${price})`);
    return <int>result.lastInsertId;
}

function deleteProduct(int id) returns int|error{
    sql:ExecutionResult result = check dbClient->execute(`DELETE FROM product WHERE id=${id}`);
    return <int>result.affectedRowCount;
}