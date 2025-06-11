import ballerina/http;
import ballerina/log;
import ballerinax/health.fhir.r4;

// @http:ServiceConfig {
//     auth: [
//         {
//             fileUserStoreConfig: {},
//             scopes: ["admin"]
//         }
//     ]
// }
service http:InterceptableService /a on new http:Listener(8081) {
    resource function get r4/send/[string id](http:Caller caller, http:Request httpRequest) returns error? {

        if id == "101" || id == "102" {
            http:Response res200 = new;
            res200.statusCode = 200;
            res200.setPayload("Request processed successfully for ID: " + id);
            check caller->respond(res200);
        } else if id == "103" {
            http:Response res400 = new;
            res400.statusCode = 400;
            res400.setPayload("Bad Request: Invalid ID provided.");
            check caller->respond(res400);
        } else if id == "104" {
            http:Response res401 = new;
            res401.statusCode = 401;
            res401.setPayload("Unauthorized: You need to log in to access this resource.");
            check caller->respond(res401);
        } else if id == "105" {
            http:Response res500 = new;
            res500.statusCode = 500;
            res500.setPayload("Internal Server Error: An unexpected error occurred.");
            check caller->respond(res500);
        }

        else {
            http:Response res404 = new;
            res404.statusCode = 404;
            res404.setPayload("Resource not found for ID: " + id);
            check caller->respond(res404);
        }

    }

    public function createInterceptors() returns AnalyticsResponseInterceptor {
        r4:ResourceAPIConfig apiConfig = {
            resourceType: "Patient",
            operations: [],
            authzConfig: (),
            profiles: [],
            defaultProfile: (),
            searchParameters: [],
            serverConfig: ()
        };
        return new AnalyticsResponseInterceptor(apiConfig);
    }
}

// This service is used to simulate a moreInfo endpoint to fetch additional patient information
// @http:ServiceConfig {
//     auth: [
//         {
//             fileUserStoreConfig: {},
//             scopes: ["admin"]
//         }
//     ]
// }
service http:Service /b on new http:Listener(8082) {
    resource function post more_info(map<string> payload) returns json|error {

        map<json> users_more_info = {
            "Patient/101": {"contract": "Contract 1", "plan": "Plan A"},
            "Patient/102": {"contract": "Contract 2", "plan": "Plan B"}
        };

        log:printInfo("Received payload: " + payload.toString());
        string? fhirUser = payload["fhirUser"];
        if fhirUser is string {
            json moreInfo = users_more_info[fhirUser];
            log:printInfo("Returning more info for user: " + fhirUser);
            return moreInfo;
        } else {
            log:printError("fhirUser not provided in payload");
            return {};
        }
    }

}
