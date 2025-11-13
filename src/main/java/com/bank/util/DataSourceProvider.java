package com.bank.util;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

import javax.sql.DataSource;

public class DataSourceProvider {
    private static HikariDataSource ds;

    public static DataSource getDataSource() {
        if (ds != null) return ds;
        HikariConfig cfg = new HikariConfig();

        // read from environment variables if present (recommended), otherwise use defaults
        String url = System.getenv().getOrDefault("DB_URL",
                "jdbc:mysql://127.0.0.1:3306/banking?useSSL=false&allowPublicKeyRetrieval=true");
        String user = System.getenv().getOrDefault("DB_USER", "bankuser");
        String pass = System.getenv().getOrDefault("DB_PASS", "bankpass");

        cfg.setJdbcUrl(url);
        cfg.setUsername(user);
        cfg.setPassword(pass);

        // pool settings — adjust later if needed
        cfg.setMaximumPoolSize(10);
        cfg.setMinimumIdle(2);
        cfg.setConnectionTimeout(30000);
        cfg.setIdleTimeout(600000);
        cfg.setMaxLifetime(1800000);

        // useful MySQL optimizations
        cfg.addDataSourceProperty("cachePrepStmts", "true");
        cfg.addDataSourceProperty("prepStmtCacheSize", "250");
        cfg.addDataSourceProperty("prepStmtCacheSqlLimit", "2048");

        ds = new HikariDataSource(cfg);
        return ds;
    }

    public static void close() {
        if (ds != null) {
            ds.close();
            ds = null;
        }
    }
}
