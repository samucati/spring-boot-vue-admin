<template>
  <div class="app-container">
    <el-form
      v-loading.body="loading"
      :model="tmpAccount"
      :rules="updateDetailRules"
      ref="tmpAccount"
      label-width="115px"
    >
      <el-row :gutter="18">
        <el-col :span="9">
          <el-form-item label="Nome da conta" prop="name">
            <el-input v-if="toUpdate" v-model="tmpAccount.name" />
            <span v-else>{{ tmpAccount.name }}</span>
          </el-form-item>
        </el-col>
        <el-col :span="9">
          <el-form-item label="Correspondência" prop="email">
            <el-input v-if="toUpdate" v-model="tmpAccount.email" />
            <span v-else>{{ tmpAccount.email }}</span>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="18">
        <el-col :span="9">
          <el-form-item label="Horário de registro"><span>{{ unix2CurrentTime(account.registerTime) }}</span></el-form-item>
        </el-col>
        <el-col :span="9">
          <el-form-item label="Última hora de login"><span>{{ unix2CurrentTime(account.loginTime) }}</span></el-form-item>
        </el-col>
      </el-row>
      <el-form-item>
        <el-row :gutter="18">
          <el-col :span="6">
            <el-button type="success" :loading="btnLoading" @click.native.prevent="regainAccountDetail">重新获取信息</el-button>
          </el-col>

          <el-col :span="6" v-if="!toUpdate">
            <el-button type="primary" :loading="btnLoading" @click.native.prevent="toUpdate = !toUpdate">修改信息</el-button>
          </el-col>
          <el-col :span="6" v-else>
            <el-button type="primary" :loading="btnLoading" @click.native.prevent="updateDetail">确认修改</el-button>
            <el-button type="warning" @click.native.prevent="toUpdate = !toUpdate">取消修改</el-button>
          </el-col>
          
          <el-col :span="6">
            <el-button type="danger" @click.native.prevent="showUpdatePasswordDialog">修改密码</el-button>
          </el-col>
        </el-row>
      </el-form-item>
    </el-form>

    <el-dialog title="Alterar a senha" :visible.sync="dialogFormVisible">
      <el-form
        status-icon
        class="small-space"
        label-position="left"
        label-width="115px"
        style="width: 400px; margin-left:50px;"
        :model="tmpPassword"
        :rules="updatePasswordRules"
        ref="tmpPassword"
      >
        <el-form-item label="Senha Antiga" prop="oldPassword" required>
          <el-input
            type="password"
            prefix-icon="el-icon-edit"
            auto-complete="off"
            placeholder="Por favor, digite a senha antiga"
            v-model="tmpPassword.oldPassword"
          />
        </el-form-item>
        <el-form-item label="Nova Senha" prop="newPassword" required>
          <el-input
            type="password"
            prefix-icon="el-icon-edit"
            auto-complete="off"
            placeholder="Por favor, digite uma nova senha"
            v-model="tmpPassword.newPassword"
          />
        </el-form-item>
        <el-form-item label="Nova Senha" prop="newPassword2" required>
          <el-input
            type="password"
            prefix-icon="el-icon-edit"
            auto-complete="off"
            placeholder="Por favor, digite a nova senha novamente"
            v-model="tmpPassword.newPassword2"
          />
        </el-form-item>
      </el-form>
      <div slot="footer" class="dialog-footer">
        <el-button @click.native.prevent="dialogFormVisible = false">Cancelar</el-button>
        <el-button type="danger" @click.native.prevent="$refs['tmpPassword'].resetFields()">Redefinir</el-button>
        <el-button type="primary" :loading="btnLoading" @click.native.prevent="updatePassword">Renovar</el-button>
      </div>
    </el-dialog>
  </div>
</template>

<script>
import store from '@/store'
import { update as updateAccount, validatePassword } from '@/api/account'
import { unix2CurrentTime } from '@/utils'
import { isValidateEmail } from '@/utils/validate'
import { setToken } from '@/utils/token'
import { mapState } from 'vuex'

export default {
  created() {
    this.setDetail()
  },
  data() {
    const validateOldPassword = (rule, value, callback) => {
      if (value.length < 6) {
        callback(new Error('O comprimento da senha deve ser 6 ou mais'))
      }
      // promise异步查询后端密码
      this.validateOldPassword(value).then(isValidate => {
        if (!isValidate) {
          callback(new Error('Senha antiga incorreta'))
        } else {
          callback()
        }
      })
    }
    const validateNewPassword = (rule, value, callback) => {
      if (value.length < 6) {
        callback(new Error('O comprimento da senha deve ser 6 ou mais'))
      } else if (this.isOldNewPasswordSame()) {
        callback(new Error('Senhas antigas e novas não podem ser iguais'))
      } else {
        callback()
      }
    }
    const validateNewPassword2 = (rule, value, callback) => {
      if (value.length < 6) {
        callback(new Error('O comprimento da senha deve ser 6 ou mais'))
      } else if (!this.isNewPasswordSame()) {
        callback(new Error('As senhas digitadas duas vezes não correspondem'))
      } else {
        callback()
      }
    }
    const validateName = (rule, value, callback) => {
      if (value.length < 3) {
        callback(new Error('O comprimento do nome da conta deve ser 3 ou mais'))
      } else {
        callback()
      }
    }
    const validateEmail = (rule, value, callback) => {
      if (!isValidateEmail(value)) {
        callback(new Error('Erro de formato de e-mail'))
      } else {
        callback()
      }
    }
    return {
      loading: false,
      btnLoading: false,
      dialogFormVisible: false,
      toUpdate: false,
      tmpPassword: {
        oldPassword: '',
        newPassword: '',
        newPassword2: ''
      },
      updatePasswordRules: {
        oldPassword: [
          { required: true, trigger: 'blur', validator: validateOldPassword }
        ],
        newPassword: [
          { required: true, trigger: 'blur', validator: validateNewPassword }
        ],
        newPassword2: [
          { required: true, trigger: 'blur', validator: validateNewPassword2 }
        ]
      },
      tmpAccount: {
        id: '',
        name: '',
        email: ''
      },
      updateDetailRules: {
        name: [{ required: true, trigger: 'blur', validator: validateName }],
        email: [{ required: true, trigger: 'blur', validator: validateEmail }]
      }
    }
  },
  computed: {
    ...mapState({
      account: state => state.account
    })
  },
  methods: {
    unix2CurrentTime,
    /**
     * 设置用户资料
     */
    setDetail() {
      this.tmpAccount.name = this.account.name
      this.tmpAccount.email = this.account.email
    },
    /**
     * 验证旧密码
     * @param oldPassword 旧密码
     */
    validateOldPassword(oldPassword) {
      const account = {
        id: this.account.accountId,
        password: oldPassword
      }
      return validatePassword(account).then(response => response.data)
    },
    /**
     * 新旧密码是否相同
     */
    isOldNewPasswordSame() {
      return this.tmpPassword.oldPassword === this.tmpPassword.newPassword
    },
    /**
     * 新密码1和2是否相同
     */
    isNewPasswordSame() {
      return this.tmpPassword.newPassword === this.tmpPassword.newPassword2
    },
    /**
     * 重置token
     */
    resetToken(token) {
      setToken(token)
      this.account.token = token
    },
    /**
     * 重新获取用户信息
     */
    regainAccountDetail() {
      this.loading = true
      this.btnLoading = true
      store.dispatch('Detail').then(() => {
        this.loading = false
        this.btnLoading = false
      })
    },
    /**
     * 更新用户
     * @param account 用户
     */
    updateAccount(account) {
      this.btnLoading = true
      updateAccount(account).then(response => {
        this.$message.success('Atualização completa')
        this.resetToken(response.data)
        this.regainAccountDetail()
        this.btnLoading = false
      }).catch(res => {
        this.$message.error('Atualização falhou')
      })
    },
    /**
     * 更新用户资料
     */
    updateDetail() {
      this.$refs.tmpAccount.validate(valid => {
        if (valid) {
          this.tmpAccount.id = this.account.accountId
          this.updateAccount(this.tmpAccount)
        }
      })
    },
    /**
     * 显示更新密码对话框
     */
    showUpdatePasswordDialog() {
      this.dialogFormVisible = true
      this.tmpPassword.oldPassword = ''
      this.tmpPassword.newPassword = ''
      this.tmpPassword.newPassword2 = ''
    },
    /**
     * 更新密码
     */
    updatePassword() {
      this.$refs.tmpPassword.validate(valid => {
        if (valid) {
          const account = {}
          account.id = this.account.accountId
          account.password = this.tmpPassword.newPassword
          this.updateAccount(account)
          this.dialogFormVisible = false
        }
      })
    }
  }
}
</script>
