<?php
if( $_FILES['file']['name'] != "" )
{
   move_uploaded_file( $_FILES['file']['tmp_name'], "/var/www/uploads/" . $_FILES['file']['name'] ) or
           die( "Could not copy file!");
}
else
{
    die("No file specified!");
}
?>
<!doctype HTML>
<html>
<head>
    <title>Uploading Complete</title>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />

    <!--[if IE]>
    <meta http-equiv="X-UA-Compatible" content="IE=8">
    <![endif]-->

    <link rel="shortcut icon" href="static/img/favicon.ico" type="image/x-icon" />

    <!-- google fonts -->
    <link href='https://fonts.googleapis.com/css?family=Ubuntu:400,300,300italic,400italic,700,700italic%7CUbuntu+Mono' rel='stylesheet' type='text/css' />

    <!-- stylesheets -->
    <link rel="stylesheet" type="text/css" media="screen" href="//assets.ubuntu.com/sites/guidelines/css/responsive/latest/ubuntu-styles.css" />
    <link rel="stylesheet" type="text/css" media="screen" href="static/css/base.css" />
<body>
    <header class="banner global" role="banner">
      <nav role="navigation">
          <div class="logo">
              <a class="logo-ubuntu" href="/">
                  <img width="73" height="30" src="static/img/logo.png" alt="Juju" />
              </a>
          </div>
      </nav>
    </header>
    <div class="wrapper">
        <div class="inner-wrapper">
            <div class="row no-border">
                <h2>Deployment in progress...</h2>
                <p>
                    Please wait while we deploy your environment. Refresh this
                    page to see if it is ready.
                </p>
            </div>
        </div>
    </div>
</body>
</html>
