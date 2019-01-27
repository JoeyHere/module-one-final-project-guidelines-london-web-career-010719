class User < ActiveRecord::Base
  has_many :user_artists
  has_many :artists, through: :user_artists

  attr_accessor :score

  @@current = nil

  def self.current
    @@current
  end

  def self.current=(user)
    @@current = user
  end

  def password_checker(password)
    password == self.password ?  true : false
  end

  def update_password(password)
    self.update(password: password)
  end

  def check_password
    brk
    password = password_prompt('🔐   Please enter your password.')
    brk
     if self.password_checker(password) == true
       brk
       puts "Welcome back"
       User.current = self
       return main_menu(User.current)
     else
       brk
       menu = TTY::Prompt.new
        brk
        selection = menu.select("Wrong password, wanna try again?") do |a|
          a.choice 'Try again'
          a.choice 'Back to menu'
        end
        if selection == 'Try again'
          check_password
        elsif selection == 'Back to menu'
           start_menu
       end
     end
 end

 def enter_artists
   puts "✏️   Please enter one of your favourite artists."
   while self.artists.length < 5
    brk
    puts "We only need #{5 - self.artists.length} more." if self.artists.length < 5 && self.artists.length > 0
    brk
    artist_name = check_artists(get_input)

    if !artist_name.nil?
       artist = Artist.find_by(name: artist_name)
       if artist.nil?
          self.artists << Artist.create(name: artist_name)
          puts "Got it! " + Rainbow(artist_name).green + " has been added!"
          sleep 1
       elsif self.artists.select{|a| a.id == artist.id}.first.nil?
          self.artists << artist
          puts "Got it! " + Rainbow(artist_name).green + " has been added!"
          sleep 1
       else
          puts "You already have this artist!"
       end
    else
      brk
       puts "We can't find this Artist, try again."
       brk
       enter_artists
    end
    big_brk
    show_artists
  end
  sleep 2
  main_menu(User.current)
 end

 def change_artists
    prompt = TTY::Prompt.new
    brk
    show_artists
    brk
    selection = prompt.select("Do you want to change the list of your artists?") do |a|
       a.choice 'no'
       a.choice 'yes'
     end
     if selection == 'yes'
       self.artists.destroy_all
       self.enter_artists
    else
       main_menu(User.current)
    end
  end

 def suggest_X_artists(x)
   suggested = self.artists.map {|a| a.similar_artists}.flatten.uniq.shuffle.first(x)
   suggested = suggested.map{|a| {:Suggested => a.name}}
   Formatador.display_table(suggested)
 end


  def update_highscore(score)
    self.update(highscore: score) if self.highscore < score
  end

  def self.rank
    users_arr = self.order(highscore: :desc)
    table_data = users_arr.limit(10).map {|i| {:NAME => i.name, :SCORE => i.highscore}}
    table_data[0][:NAME] = "🥇 #{table_data[0][:NAME]}" if table_data[0]
    table_data[1][:NAME] = "🥈 #{table_data[1][:NAME]}" if table_data[1]
    table_data[2][:NAME] = "🥉 #{table_data[2][:NAME]}" if table_data[2]
    Formatador.display_table(table_data)
  end


  def show_artists
    table_data = self.artists.map {|a| {:ARTIST => a.name}}
    Formatador.display_table(table_data)
  end


end
