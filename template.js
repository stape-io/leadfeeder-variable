const sendHttpRequest = require('sendHttpRequest');
const getRemoteAddress = require('getRemoteAddress');
const encodeUriComponent = require('encodeUriComponent');
const templateDataStorage = require('templateDataStorage');
const getEventData = require('getEventData');
const sha256Sync = require('sha256Sync');
const JSON = require('JSON');


let ip = data.ip ? data.ip : (getEventData('ip_override') ? getEventData('ip_override'): getRemoteAddress());
let url = 'https://api.lf-discover.com/companies?ip='+enc(ip);
let requestOptions = {
    headers: {
        'Accept': 'application/json',
        'User-Agent': 'Stape',
        'X-API-KEY': data.apiKey
    },
    method: 'GET',
    timeout: 10000
};

return sendRequest(url, requestOptions);

function sendRequest(url, requestOptions) {
    let cacheKey = sha256Sync(url + JSON.stringify(requestOptions) + data.jsonParseKeyName);

    if (data.storeResponse) {
        const cachedBody = templateDataStorage.getItemCopy(cacheKey);

        if (cachedBody) return cachedBody;
    }

    return sendHttpRequest(url, requestOptions).then((successResult) => {
        if (successResult.statusCode === 301 || successResult.statusCode === 302) {
            return sendRequest(successResult.headers['location'], requestOptions);
        }

        const parsedBody = JSON.parse(successResult.body);
        const result = data.jsonParseKey ? getByKey(data.jsonParseKeyName, parsedBody) : parsedBody;

        if (data.storeResponse) templateDataStorage.setItemCopy(cacheKey, result);

        return result;
    });
}

function getByKey(keyName, obj) {
    keyName.split('.').reduce(function (p, c) {
        return p && p[c] || null;
    }, obj);
}

function enc(data) {
    data = data || '';
    return encodeUriComponent(data);
}
