class User < ActiveRecord::Base
  has_many :user_artists
  has_many :artists, through: :user_artists

  def password_checker(password)
    password == self.password ?  true : false
  end

  def update_password(password)
    self.update(password: password)
  end

  def check_password
    brk
    password = password_prompt('Please enter your password.')
    brk
     if self.password_checker(password) == true
       brk
       puts "Welcome back"
       return self
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
  while self.artists.length < 5
    brk
    puts "Please enter your favourite artists."
    brk
    artist_name = check_artists(get_input)

    if !artist_name.nil?
       artist = Artist.find_by(name: artist_name)
       if artist.nil?
          self.artists << Artist.create(name: artist_name)
          puts "Got it! #{artist_name} has been added!"
       elsif self.artists.select{|a| a.id == artist.id}.first.nil?
          self.artists << artist
          puts "Got it! #{artist_name} has been added!!"
       else
          puts "You already have this artist!"
       end
    else
        brk
       puts "We can't find this #{artist_name}. Try again."
       enter_artists
    end

  end

 end

 def change_artists
    prompt = TTY::Prompt.new
    # puts "Do you want to change the list of your artists?"
    brk
    selection = prompt.select("Do you want to change the list of your artists?") do |a|
       a.choice 'yes'
       a.choice 'no'
     end
     if selection == 'yes'
       self.artists.destroy_all
       self.enter_artists
     else
       main_menu($current_user)
     end
 end


  def add_score(score)
    self.update(highscore: score) if self.highscore < score
  end

  def self.rank
    users_arr = self.order(highscore: :desc)
    users_arr.limit(5).map {|i| "#{i.name} : #{i.highscore}"}
  end

end
