            if bool(fileName):
                flag = 1
                filePath = os.path.join(detach_dir, 'attachments', fileName)
                if not os.path.isfile(filePath) :
                    print fileName
                    fp = open(filePath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()
                else:
                    tmpPath = os.path.join(detach_dir, 'attachments', fileName+'tmp')
                    fp = open(tmpPath, 'wb')
                    fp.write(part.get_payload(decode=True))
                    fp.close()

                    # To check against all file name variants
                    fileCounter = 1
                    while not filecmp.cmp(filePath, tmpPath):
                        newName = fileName.split('.')
                        newName = '.'.join(newName[:-1]) + '.' + str(fileCounter) + '.' + newName[-1]
                        newPath = os.path.join(detach_dir, 'attachments', newName)
                        if os.path.isfile(newPath):
                            filePath = newPath
                            fileCounter += 1
                        else:
                            os.rename(tmpPath, newPath)
                            break
                    if filecmp.cmp(filePath, tmpPath):
                        os.remove(tmpPath)
