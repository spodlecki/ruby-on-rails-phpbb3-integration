# Ruby on Rails \& phpBB 3 User Integration

This sample code is to demonstrate how you can use a Ruby on Rails with phpBB3's user system. It is simple and effective.

First, I am not the author of most of this code. The original code can be found on this website: <http://www.trdev.co.uk/2011/01/25/single-sign-on-with-phpbb-and-ruby-on-rails/>.

The reason I'm sharing this version of the code is because I couldn't find anything else on the internet. Most of the code out there didn't work, at all.

You are more than welcome to edit to your suit your needs, but I've commented in the code as much as I felt it needed.

## A few comments on the original website

I feel <http://www.trdev.co.uk/2011/01/25/single-sign-on-with-phpbb-and-ruby-on-rails/> was getting a bit too complicated with the login... All you will need to do is to create a form, nothing more. The sample login form is in the users/login partial.

## The only real thing to note...
- You will need to edit your database.yml and add phpBB test, dev, and production links. Not sure about you, but I work & test locally before anything hits an actual server.
- You will need to check your admin configuration and modify some of the user.rb code
- By using this code, you do so at your own will. No one is responsible for it except for yourself.

## No, I'm not making this into a gem. Use the code as-is and happy coding!