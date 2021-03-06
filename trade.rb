require 'btce'

PROFIT_MARGIN = 0.006 # btc-e charges .02% to buy and .02% to sell, so we'll make .02% in profit
PAIR = "ltc_btc"
AMOUNT = "0.998"
SLEEP_DURATION = 1 # Amount of time to wait before pinging server again

while true do # ping btce forever
  order_placed = false
  sleep SLEEP_DURATION # added this to prevent nonce increment errors (pinging server too fast)

  order_list = Btce::TradeAPI.new_from_keyfile.order_list
  p order_list
  # go through all current orders and see if this pair has a trade placed yet
  if order_list["success"] == 1
    for id in order_list["return"]
      if id[1]["pair"] == PAIR
        order_placed = true
      end
    end
  end

  if ! order_placed # if there is no existing sell order
    ticker = Btce::Ticker.new PAIR
    # buy currency @ buy price
    rate = ticker.buy.to_s
    buy_json = {"pair" => PAIR, "type" => "buy", "rate" => rate, "amount" => AMOUNT}
    p Btce::TradeAPI.new_from_keyfile.trade buy_json

    # place sell order for PROFIT_MARGIN percentage above buy price
    rate = ((ticker.buy * PROFIT_MARGIN) + ticker.buy).round(5).to_s #rounded for btce accuracy
    sell_json = {"pair" => PAIR, "type" => "sell", "rate" => rate, "amount" => AMOUNT}
    p Btce::TradeAPI.new_from_keyfile.trade sell_json
  end
end