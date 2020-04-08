-- Burstcoin Extension for MoneyMoney
-- Fetches balances from cryptoguru.org API
--
-- Copyright (c) 2018 CurbShifter
-- BURST-WN56-VW53-7B6V-9YAFW
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

WebBanking{
  version = 0.1,
  description = "Include your BURST as cryptoportfolio in MoneyMoney by providing BURST numeral addresses as usernme (comma seperated)",
  services= { "Burstcoin" }
}

local burstcoinAddress
local connection = Connection()
local currency = "EUR"

function SupportsBank (protocol, bankCode)
  return protocol == ProtocolWebBanking and bankCode == "Burstcoin"
end

function InitializeSession (protocol, bankCode, username, username2, password, username3)
  burstcoinAddress = username:gsub("%s+", "")
end

function ListAccounts (knownAccounts)
  local account = {
    name = "Burstcoin",
    accountNumber = "Burstcoin",
    currency = currency,
    portfolio = true,
    type = "AccountTypePortfolio"
  }

  return {account}
end

function RefreshAccount (account, since)
  local s = {}
  prices = requestBurstcoinPrice()

  for address in string.gmatch(burstcoinAddress, '([^,]+)') do
    BurstcoinQuantity = requestBurstcoinQuantityForburstcoinAddress(address)

    s[#s+1] = {
      name = address,
      currency = nil,
      market = "cryptocompare",
      quantity = BurstcoinQuantity,
      price = prices,
    }
  end

  return {securities = s}
end

function EndSession ()
end

function requestBurstcoinPrice()
  response = connection:request("GET", cryptocompareRequestUrl(), {})
  json = JSON(response)

  return json:dictionary()['EUR']
end

function getBalanceFromJSON(data)
    return data["balance"]
end

function requestBurstcoinQuantityForburstcoinAddress(burstcoinAddress)
  response = connection:request("GET", BurstcoinRequestUrl(burstcoinAddress), {})
  json = JSON(response)
  plancks = json:dictionary()["data"]["balance"]
  bursts = 0;
  if ( plancks ) then
    bursts = plancks / 100000000
  end
  return bursts
end

function cryptocompareRequestUrl()
  return "https://min-api.cryptocompare.com/data/price?fsym=BURST&tsyms=EUR"
end

function BurstcoinRequestUrl(burstcoinAddress)
  return "https://explore.burst.cryptoguru.org/api/v1/account/" .. burstcoinAddress
end
