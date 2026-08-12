<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            // Default mass-offering amount (XOF). Null falls back to 3000.
            $table->unsignedInteger('mass_offering_amount')->nullable()->after('cinetpay_secret_key');
        });
    }

    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->dropColumn('mass_offering_amount');
        });
    }
};
