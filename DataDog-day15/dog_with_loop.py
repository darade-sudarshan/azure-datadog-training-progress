if __name__ == '__main__':
    from selenium import webdriver
    from selenium.webdriver.common.by import By
    import undetected_chromedriver as uc
    import logging
    from pythonjsonlogger import jsonlogger 
    import itertools
    from time import sleep
    
    options = uc.ChromeOptions()
    options.add_argument("--incognito")
    driver = uc.Chrome(executable_path="chromedriver.exe",options=options)
    driver.maximize_window()
    
    #logging
    logger = logging.getLogger()

    logHandler = logging.FileHandler(filename='C:/ProgramData/Datadog/log.json')
    formatter = jsonlogger.JsonFormatter()
    logHandler.setFormatter(formatter)
    logger.addHandler(logHandler)
    logger.setLevel(logging.INFO)
    
    try:
        driver.get("https://www.amazon.com/")
        self.driver.find_element(By.XPATH, value="//div[contains(@class,'product')]")
        
    except:
        for x in itertools.repeat(1): 
            logger.info('Product not found in website', extra={'referral_code': '79vn4et'})
            sleep(1)
    
    driver.quit()