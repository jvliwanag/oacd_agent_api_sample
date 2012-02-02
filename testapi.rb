#!/usr/bin/env ruby

require 'json'
require 'net/http'

include Net

def do_req(uri, function, args=[], cookie="")
	str = {:function => function, :args => args}.to_json
	body = HTTP.post_form(uri, {:request => str, :cookie => cookie}).body
	JSON.parse(body)
end

uri = URI('http://localhost:5050/api')
username = "agent"
password = "Password123"

puts "Calling get_salt..."
salt_resp = do_req(uri, "get_salt")
puts salt_rep

key = OpenSSL::PKey::RSA.new
key.e = OpenSSL::BN.new(salt_resp['result']['pubkey']['E'], 16)
key.n = OpenSSL::BN.new(salt_resp['result']['pubkey']['N'], 16)

salt = salt_resp['result']['salt']

pass_dec = salt + password
pass_enc = key.public_encrypt(pass_dec).unpack('H*')[0]

cookie = salt_resp['result']['cookie']
options = {:voipendpoint => "pstn",
	:voipendpointdata => "sip:123@liwanag.me",
	:useoutbandring => true}

puts "Calling login..."
login_resp = do_req(uri, "login", [username, pass_enc, options], cookie)
puts login_resp

puts "Calling get_agent_profiles"
puts do_req(uri, "get_agent_profiles", [], cookie)

puts "Calling get_agent_profiles"
puts do_req(uri, "get_agent_profiles", [], cookie)

puts "Calling ring_test"
puts do_req(uri, "ring_test", [], cookie)

puts "Calling logout"
puts do_req(uri, "logout", [], cookie)