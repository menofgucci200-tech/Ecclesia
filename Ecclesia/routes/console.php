<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Keep the liturgy up to date automatically (today + the next 2 days).
Schedule::command('liturgy:sync --days=3')->dailyAt('04:00')->withoutOverlapping();
