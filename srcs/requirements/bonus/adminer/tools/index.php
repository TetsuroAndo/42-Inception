<?php
    if (file_exists('./adminer.php')) {
        require('./adminer.php');
    } else {
        // Adminerの最新バージョンをダウンロード
        $adminerUrl = 'https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php';
        $adminerContent = file_get_contents($adminerUrl);
        if ($adminerContent) {
            file_put_contents('./adminer.php', $adminerContent);
            require('./adminer.php');
        } else {
            die('Error: Could not download Adminer');
        }
    }
?>
