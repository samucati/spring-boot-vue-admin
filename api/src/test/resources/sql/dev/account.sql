
DROP TABLE IF EXISTS `account`;
CREATE TABLE `account`
(
    `id`            bigint(20) unsigned                             NOT NULL AUTO_INCREMENT COMMENT '用户Id',
    `email`         varchar(64) CHARACTER SET utf8 COLLATE utf8_bin COMMENT '邮箱',
    `name`          varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL COMMENT '用户名',
    `password`      varchar(512) CHARACTER SET utf8 COLLATE utf8_bin COMMENT '密码',
    `register_time` datetime DEFAULT NOW() COMMENT '注册时间',
    `login_time`    datetime DEFAULT NULL COMMENT '上一次登录时间',
    PRIMARY KEY (`id`),
    UNIQUE KEY `ix_account_name` (`name`),
    UNIQUE KEY `ix_account_email` (`email`)
) ENGINE = InnoDB
  AUTO_INCREMENT = 4
  DEFAULT CHARSET = utf8mb4 COMMENT ='用户表';

LOCK TABLES `account` WRITE;

INSERT INTO `account`
VALUES (1, 'admin@qq.com', 'admin', '$2a$10$wg0f10n.30UbU.9hPpucbef/ya62LdTKs72xJfjxvTFsL0Xaewbra',
        '2019-07-01 00:00:00', '2019-07-01 00:00:00');
INSERT INTO `account`
VALUES (2, 'editor@qq.com', 'editor', '$2a$10$/m4SgZ.ZFVZ7rcbQpJW2tezmuhf/UzQtpAtXb0WZiAE3TeHxq2DYu',
        '2019-07-02 00:00:00', '2019-07-02 00:00:00');
INSERT INTO `account`
VALUES (3, 'test@qq.com', 'test', '$2a$10$.0gBYBHAtdkxUUQNg3kII.fqGOngF4BLe8JavthZFalt2QIXHlrhm',
        '2019-07-03 00:00:00', '2019-07-03 00:00:00');

UNLOCK TABLES;

