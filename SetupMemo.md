# Setup on Mac

### Preparations
```
sudo gem update --system -n /usr/local/bin --no-document
```

### Create scaffold of app

```
PROJECT=rubystrap

bundle gem $PROJECT
cd $PROJECT
touch SetupMemo.md # make this file
vi $PROJECT.gemspec
```

### Write the source codes

```
gem build rubypivot.gemspec # -o ./gems/rubypivot-new.gem
gem install rubypivot-0.0.1.gem # ./gems/rubypivot-new.gem
```

### Release

bundle exec rake release