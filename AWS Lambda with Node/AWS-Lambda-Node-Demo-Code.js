// A Node file that uses Serverless Chrome to take a screenshot and capture a table.
// The table is formatted and emailed through an API to a client email.
// Note: software.com is a fictional company to replace the real site.

// handler.js
const puppeteer = require('puppeteer')
const launchChrome = require('@serverless-chrome/lambda')
const superagent = require('superagent')
const request = require('request')
const request2 = require('request')
const fs = require('fs')

// Retrieve Username and Password from ENV Variables
const User = process.env.USER
const PlusUser = process.env.PLUSUSER
const Password = process.env.PASSWORD
const APIUser = process.env.APIUSER
const APIPlusUser = process.env.APIPLUSUSER
const APIPassword = process.env.APIPASSWORD
const APISecret = process.env.SECRET
const APIClientId = process.env.CLIENTID
const ClientName = process.env.CLIENTNAME


console.log('User=' + `${User}`)
console.log('Password=' + `${Password}`)
console.log('APIClientId=' + `${APIClientId}`)
console.log('APISecret=' + `${APISecret}`)

console.log('this ran getChrome')

module.exports = {
  cronDataLoad: async function () {
    let result1 = await exports.theNewToken()
    let result2 = await exports.cron()
    console.log('theNewToken ' + result1)
    console.log('cron ' + result2)
  }
}

// the below works for lamba
exports.theNewToken = async function (event, context, callback) {
  const EventEmitter = require('events').EventEmitter
  const body = new EventEmitter()
  const options2 = {
    method: 'POST',
    url: 'https://restapi.software.com/token',
    headers:
    {
      'cache-control': 'no-cache',
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    form:
    {
      grant_type: 'password',
      username: `${APIUser}`,
      password: `${APIPassword}`,
      client_id: `${APIClientId}`,
      client_secret: `${APISecret}`
    }
  }

  request(options2, function (error, response, data) {
    body.data = data
    console.log('error:', error) // Print the error if one occurred
    const accessContents = JSON.parse(data)
    const accessToken = (accessContents.access_token)
    body.accessToken = accessToken
    fs.writeFileSync('/tmp/accessToken.txt', `${accessToken}`, function (err) {
      if (err) {
        return console.log(err)
      }
    })
    console.log('Token Write Success ' + `${accessToken}`)
  })
}

exports.cron = async function (event, context, callback) {
  console.log('this ran cron')
  const chrome = await getChrome()
  const browser = await puppeteer.connect({
    browserWSEndpoint: chrome.endpoint
  })
  const page = await browser.newPage()
  console.log('Finished browser.newPage')
  await page.goto('https://www.software.com/acton/account/login.jsp', { waitUntil: 'networkidle0' })
  console.log('Finished software login')
  await page.type('#login', User)
  console.log('Finished PlusUser ' + User)
  await page.type('#pw', Password)
  console.log('Finished Password ' + Password)
  await page.waitFor(2000)
  let selector = '#loginbutton'
  await page.evaluate((selector) => document.querySelector(selector).click(), selector)
  console.log('Finished loginbutton')
  await page.waitForNavigation({ waitUntil: 'load' })
  console.log('Finished software load')
  await page.goto('https://software.com', { waitUntil: 'networkidle0' })
  console.log('Finished results page')
  // await page.screenshot({ path: 'screenshot.png' })
  // console.log('Finished Google Login and SugarPage')

  // Totally lucky guess at how to pull in an unnamed table. Please name tables.
  const LastRunHTML = await page.evaluate(() => {
    const rows = document.getElementsByTagName('table')[1].rows
    const last = rows[rows.length - 1]
    const cell = last.cells[0]
    const value = cell.innerHTML
    return value
  })

  try {
    var newAccessToken = fs.readFileSync('/tmp/accessToken.txt', 'utf8')
    console.log('Token Read Success ' + newAccessToken)
  } catch (e) {
    console.log('Error in Token Read:', e.stack)
  }

  const MessageOptions = {
    method: 'POST',
    url: 'https://restapi.software.com/api/1/message/d-0004/send',
    headers:
    {
      'cache-control': 'no-cache',
      'Authorization': 'Bearer ' + `${newAccessToken}`,
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    form:
    {
      'senderemail': `${APIUser}`,
      // 'senderemail': `${APIPlusUser}`,
      'sendername': `${ClientName}`,
      'sendtorecids': 'l-0002%3A0',
      'when': '1563987000000',
      'subject': 'Contacts%20Report',
      'htmlbody': `${LastRunHTML}`,
      'textbody': `${LastRunHTML}`
    }
  }

  await request2.post(MessageOptions, function (error, response, body) {
    console.log('error:', error) // Print the error if one occurred
    console.log('statusCode:', response && response.statusCode) // Print the response status code if a response was received
    console.log('body:', body)
    console.log('Finished Sending Request2')
  })

  await browser.close()
  console.log('closed browser')
  setTimeout(() => chrome.instance.kill(), 0)
  console.log('End of Line')
}

const getChrome = async () => {
  const chrome = await launchChrome()

  const response = await superagent
    .get(`${chrome.url}/json/version`)
    .set('Content-Type', 'application/json')

  const endpoint = response.body.webSocketDebuggerUrl

  return {
    endpoint,
    instance: chrome
  }
}
