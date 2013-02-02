Feature: Sitemap
  As a designer
  I want to have an automatically generated sitemap

Background:
  Given I have the site: "test site" set up

Scenario: Simple sitemap
  Given a page named "about" with the template:
    """
    <html>
      <body>About us</body>
    </html>
    """
  When I go to the sitemap
  Then the response status should be 200
  And I should see the following xml output:
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>http://test.example.com:9886</loc>
        <priority>1.0</priority>
      </url>
      <url>
        <loc>http://test.example.com:9886/about</loc>
        <lastmod>:now</lastmod>
        <priority>0.9</priority>
      </url>
    </urlset>
    """

Scenario: Templatized page
  Given I have a custom model named "Articles" with
      | label       | type      | required    |
      | Title       | string    | true        |
      | Body        | text      | true        |
  And I have entries for "Articles" with
    | title             | body                    |
    | Hello world       | Lorem ipsum             |
    | Lorem ipsum       | Lorem ipsum...          |
  And a templatized page for the "Articles" model and with the template:
    """
    <html>
      <body>Template for an article</body>
    </html>
    """
  When I go to the sitemap
  Then the response status should be 200
  And I should see the following xml output:
    """
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      <url>
        <loc>http://test.example.com:9886</loc>
        <priority>1.0</priority>
      </url>
      <url>
        <loc>http://test.example.com:9886/articles</loc>
        <lastmod>:now</lastmod>
        <priority>0.9</priority>
      </url>
      <url>
        <loc>http://test.example.com:9886/articles/hello-world</loc>
        <lastmod>:now</lastmod>
        <priority>0.9</priority>
      </url>
      <url>
        <loc>http://test.example.com:9886/articles/lorem-ipsum</loc>
        <lastmod>:now</lastmod>
        <priority>0.9</priority>
      </url>
    </urlset>
    """