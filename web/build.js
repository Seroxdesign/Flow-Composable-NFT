const fs = require('fs');
const path = require('path');
const transactionsPath = path.join(__dirname, '..', 'cadence', 'transactions', '/')
const scriptsPath = path.join(__dirname, '..', 'cadence', 'scripts', '/')

const convertCadenceToJs = async () => {
    const resultingJs = await require('cadence-to-json')({
        transactions: [ transactionsPath ],
        scripts: [ scriptsPath ],
        config: require('../flow.json')
    })

    var networks = {}
    for (const [key, value] of Object.entries(resultingJs.vars)) {
        var addressMap = {}
        for (const [key2, value2] of Object.entries(value)) {
            const newKey = key2.replace('0x', '')
            addressMap[newKey] = value2
        }
        networks[key] = addressMap
    }

    fs.writeFile(path.join(__dirname, 'src', 'cadut', "addressMap.json"), JSON.stringify(networks), (err) => {
        if (err) {
            console.log('Failed to write file', err)
        } else {
            console.log('Successfully wrote address map file')
        }
    })
}

convertCadenceToJs()