import ballerina/http;

service / on new http:Listener(9090) {
    
    resource function get products() returns ProductRecord[]|error?{
        return getProducts();
    }

    resource function post products(@http:Payload ProductRecord product) returns ProductRecord{

        int|error result = addProduct(product);
        return product;
    }

    resource function post followProduct() returns error? {

    }
}
