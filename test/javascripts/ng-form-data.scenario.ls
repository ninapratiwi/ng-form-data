require! {
  path
}

(...) <-! describe 'module ng-form-data'
const ptor      = protractor.getInstance!

it 'should work' !(...) ->
  ptor.get '/'

  expect element(by.css '.navbar-brand').getText! .toBe 'ng-form-data'

describe 'input[type="file"] directive' !(...) ->
  it 'should allow single file input' !(...) ->
    ptor.get '/'

    const filepath = path.join process.cwd!, '/test/fixtures/screenshot.png'
    element(by.id 'image_file').sendKeys filepath
    browser.driver.sleep 500

    element(by.css '[type="submit"]').click!
    browser.driver.sleep 15000

    expect element(by.css '.thumbnail > img:nth-child(2)').getAttribute('src') .toContain 'http://i.imgur.com/'
