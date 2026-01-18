#import <Foundation/Foundation.h>
#import <signal.h>
#import <sys/sysctl.h>
#import <unistd.h>

static void enumerateProcesses(void (^block)(pid_t pid, NSString *execPath)) {
    int mib[3] = { CTL_KERN, KERN_PROC, KERN_PROC_ALL };
    size_t size = 0;

    if (sysctl(mib, 3, NULL, &size, NULL, 0) != 0) return;

    struct kinfo_proc *procs = malloc(size);
    if (!procs) return;

    if (sysctl(mib, 3, procs, &size, NULL, 0) != 0) {
        free(procs);
        return;
    }

    int count = (int)(size / sizeof(struct kinfo_proc));
    for (int i = 0; i < count; i++) {
        pid_t pid = procs[i].kp_proc.p_pid;
        if (pid <= 0) continue;

        size_t argSize = 0;
        if (sysctl((int[]){CTL_KERN, KERN_PROCARGS2, pid}, 3, NULL, &argSize, NULL, 0) != 0)
            continue;

        char *buffer = malloc(argSize);
        if (!buffer) continue;

        if (sysctl((int[]){CTL_KERN, KERN_PROCARGS2, pid}, 3, buffer, &argSize, NULL, 0) == 0) {
            NSString *path = [NSString stringWithUTF8String:(buffer + sizeof(int))];
            if (path) {
                block(pid, path);
            }
        }

        free(buffer);
    }

    free(procs);
}

int main(int argc, char *argv[]) {
    @autoreleasepool {
        enumerateProcesses(^(pid_t pid, NSString *execPath) {
            if ([execPath.lastPathComponent isEqualToString:@"CommCenter"]) {
                kill(pid, SIGTERM);
            }
        });
    }

    return 0;
}
