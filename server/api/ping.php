<?php
/**
 * ping.php - اختبار الاتصال بالسيرفر
 */
require_once 'config.php';
successResponse(['status' => 'online', 'time' => date('Y-m-d H:i:s')], 'السيرفر متصل');
