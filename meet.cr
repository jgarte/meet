require "option_parser"

open_link = false
open_immediate = false
send_to_keybase = false
keybase_recipient = ""
meeting_name = ["meeting"]
enum TitleStyle
  SnakeCase
  Dash
  TitleCase
  ScreamCase
  Heart
  Custom
end
name_style = TitleStyle::TitleCase
custom_text = ""

def title(style, words, custom_text="")
  case style
  when TitleStyle::SnakeCase
    words.join "_"
  when TitleStyle::Dash
    words.join "-"
  when TitleStyle::TitleCase
    words.map(&.capitalize).join
  when TitleStyle::ScreamCase
    words.map(&.upcase).join("👏️") + "🗯️"
  when TitleStyle::Heart
    "❣️" + words.join("❤️") + "❣️"
  when TitleStyle::Custom
    words.join(custom_text)
  else raise "unknown title style"
  end
end

OptionParser.parse do |parser|

  parser.banner = "Usage: meet [arguments] [meeting name]"
  parser.on("-s", "--snake", "use snake_case for meeting title") {
    name_style = TitleStyle::SnakeCase
  }
  parser.on("-d", "--dash", "use dashes for meeting title") {
    name_style = TitleStyle::Dash
  }
  parser.on("-t", "--title", "use TitleCase for meeting title") {
    name_style = TitleStyle::TitleCase
  }
  parser.on("-S", "--shout", "use SHOUT👏️CASE🗯️ for meeting title") {
    name_style = TitleStyle::ScreamCase
  }
  parser.on("-h", "--heart", "use ❣️heart❤️style❣️ for meeting title") {
    name_style = TitleStyle::Heart
  }
  parser.on("-j TEXT", "--emoji=TEXT", "put TEXT between words of meeting title") do |text|
    name_style = TitleStyle::Custom
    custom_text = text
  end
  parser.on("-o", "--open", "open URL in your browser after a short pause") {
    open_link = true
  }
  parser.on("-O", "--open-immediate", "open URL in your browser immediately") {
    open_link = true
    open_immediate = true
  }
  parser.on("-k USER", "--send-kb=USER", "send URL to USER on Keybase") do |user|
    send_to_keybase = true
    keybase_recipient = user
  end

  parser.unknown_args do |args|
    meeting_name = args unless args.empty?
  end
end

def super_secure_string
  Random::Secure.base64(6)
end

title_text = title(name_style, meeting_name, custom_text)
link = "https://meet.jit.si/#{super_secure_string}/#{title_text}"
puts link
if send_to_keybase
  puts "📨️ sent link to #{keybase_recipient} on Keybase!"
  `keybase chat send --private #{keybase_recipient} "#{link}"`
end
if open_link
  puts "🌍️ opening in your browser…"
  sleep(0.5.seconds) unless open_immediate
  `xdg-open #{link}`
end
