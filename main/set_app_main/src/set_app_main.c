#include <system/system_task.h>
#include <apps/shell/tash.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/boardctl.h>
#include <system/system.h>
#include <system/system_log.h>
//#include <lwip/dhcp.h>
#include <system/system_timer.h>
#include <system/system_time.h>
#include <netutils/netlib_utils.h>
#include <log_buffer/log_buffer.h>

#include "env/inc/env.h"
#include "dacm_main/inc/dacm_main.h"
#include "dacm_scube_main/inc/dacm_scube_main.h"
#include "app_common/inc/app_common.h"
#include "Factory/inc/FactoryMode_mgmt.h"
#include "PowerSave/inc/PowerSave_mgmt.h"
#include "wifi/inc/wifi_manager.h"
#include "UartWatchDog/inc/UartWatchDog.h"
#include "tash_pwd_stub/inc/tash_pwd_stub.h"

#include "ocf/ocf_manager/inc/ocf_manager.h"
#include "cacommon.h"
#include "dacm_ocf_shp_adapter/inc/dacm_ocf_shp_adapter.h"
#include "update_event_handler/inc/update_event_subscriber.h"
#include "common_event_handler/inc/common_event_subscriber.h"
#include "dacm_ssm_main/inc/dacm_ssm_main.h"
#include "dacm_otn_main/inc/dacm_otn_main.h"

#include "OTN/include/otn_log_for_ssm.h"
#include "OTN/include/otn_wifi_update.h"

#include <prconf.h>
#include "micom/messaging/inc/micom_messaging.h"
#include "micom/manager/inc/micom_manager.h"
#include "ocf/easysetup/inc/easysetup_manager.h"


#include "set_app_main/inc/set_app_main.h"


static pthread_t gWiFiAppMainTaskID;

void set_app_main_task(void){
#ifdef CONFIG_USE_TASH_PASSWORD
        tash_pwd_stub_set_sha(CONFIG_TASH_PASSWORD_SHA256, SYSTEM_TRUE);
#else
        char empty_sha[TASH_PASSWORD_SHA256_LENGTH+1]="";
        tash_pwd_stub_set_sha(empty_sha, SYSTEM_FALSE);
#endif
}

int dawit_main(int argc, char *argv[]){
	printf("Hello World! from app");
	if (SYSTEM_SUCCESS != system_task_create(&(gWiFiAppMainTaskID), "main_task", set_app_main_task, 0, SYSTEM_NORMAL_PRIORITY, 1024 * 13)) {
                SYSTEM_LOG_CRITICAL(SYSTEM_TAG_SET_APP, "Failed run dawit main task");
                return -1;
        }
	return 0;
}
