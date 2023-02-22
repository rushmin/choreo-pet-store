import ballerina/graphql;
import ballerina/io;

type ProdcutRecord record {
    int id;
    string title;
    string description;
    string includes;
    string intended_for;
    string color;
    string material;
    decimal price;
};

service class Product{

    private final readonly & ProdcutRecord prodcutRecord;

    function init(ProdcutRecord prodcutRecord) {
        self.prodcutRecord = prodcutRecord.cloneReadOnly();
    }
    resource function get id() returns int {
        return self.prodcutRecord.id;
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


service / on new graphql:Listener(9090) {

    resource function get product() returns Product[]|error {
        return getProducts();
    }

    remote function addProduct(string title, string description, string includes,
                                                string intended_for, string color,
                                                string material, decimal price) returns int {
        int|error ret = addProduct(title, description, includes, intended_for, color, material, price);
        io:println(ret);
        return ret is error ? -1 : ret;
    }

    remote function deleteProduct(int id) returns int|error{
        return deleteProduct(id);
    }
}