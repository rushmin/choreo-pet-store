import ballerina/graphql;
import ballerina/log;

type ProductItem record {|
    int id;
    string name;
    string description;
    string image;
    decimal price;   
    string variation;
    string sku;
|};

service class ProductItems {

    private final readonly & ProductItem productItem;

    function init(ProductItem productItem){
        self.productItem = productItem.cloneReadOnly();
    }

    resource function get name() returns string {
        return self.productItem.name;
    }

    resource function get description() returns string {
        return self.productItem.description;
    }

    resource function get image() returns string {
        return self.productItem.image;
    }

    resource function get price() returns decimal {
        return self.productItem.price;
    }

    resource function get variation() returns string {
        return self.productItem.variation;
    }

    resource function get sku() returns string {
        return self.productItem.sku;
    }
}


service /catalog on new graphql:Listener(9000) {

    resource function get catalog(string? sku) returns ProductItems[] | error {
        log:printInfo("function is called ###########");
        return getProductItems(sku);
    }

    resource function get all() returns ProductItems[]|error {
      log:printInfo("function is called ###########");
        return getAllProductItems();
    }

    remote function addProductItem(string? name, string? description, string? image, 
    decimal? price, string? variation) returns int {

        log:printInfo("function is called ###########");
        int|error ret = addProductItem(name, description, image, price, variation);
        return ret is error ? -1 : ret;
    }

}