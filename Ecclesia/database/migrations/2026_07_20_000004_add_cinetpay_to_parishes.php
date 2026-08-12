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
            // Each parish holds its own CinetPay merchant credentials so funds
            // go straight to the parish. Secret values are stored encrypted
            // (hence text columns).
            $table->string('cinetpay_site_id')->nullable()->after('subscription_amount');
            $table->text('cinetpay_api_key')->nullable()->after('cinetpay_site_id');
            $table->text('cinetpay_secret_key')->nullable()->after('cinetpay_api_key');
        });
    }

    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->dropColumn(['cinetpay_site_id', 'cinetpay_api_key', 'cinetpay_secret_key']);
        });
    }
};
