<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->string('city')->nullable()->after('address');
            $table->string('commune')->nullable()->after('city');
            $table->string('region')->nullable()->after('commune');
            $table->string('country')->default('Côte d\'Ivoire')->after('region');
            $table->string('phone', 30)->nullable()->after('country');
            $table->string('email')->nullable()->after('phone');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('parishes', function (Blueprint $table) {
            $table->dropColumn(['city', 'commune', 'region', 'country', 'phone', 'email']);
        });
    }
};
